// Disneybound Planner - BAML Configuration
// This file defines the LLM functions for outfit suggestions and character matching.

// =============================================================================
// CLIENT CONFIGURATION
// =============================================================================

client<llm> Gemini {
  provider google-ai
  options {
    model "gemini-2.5-pro"
    api_key env.GOOGLE_API_KEY
  }
}

// =============================================================================
// DATA TYPES
// =============================================================================

class Character {
  name string
  movie string
  category string @description("Princess, Villain, Pixar, Marvel, Star Wars, etc.")
  primaryColors string[] @description("Main colors associated with this character")
  secondaryColors string[] @description("Accent colors")
  aestheticKeywords string[] @description("Style descriptors like 'elegant', 'rugged', 'whimsical'")
}

class ClothingItem {
  itemType string @description("top, bottom, shoes, accessory, dress, jacket")
  description string
  color string
  productUrl string?
}

class OutfitSuggestion {
  items ClothingItem[]
  explanation string @description("Why this outfit works for the character")
  colorHarmony string @description("How the colors relate to the character")
  styleNotes string @description("Tips for wearing this outfit")
}

class UserPreferences {
  budget string @description("low, medium, high")
  style string @description("casual, dressy, athletic, vintage")
  climateConsiderations string @description("hot, mild, cold, rainy")
  existingWardrobe ClothingItem[] @description("Items the user already owns")
}

// =============================================================================
// FUNCTIONS
// =============================================================================

function SuggestOutfit(character: Character, preferences: UserPreferences) -> OutfitSuggestion {
  client Gemini
  prompt #"
    You are a fashion expert specializing in Disneybounding - creating everyday outfits
    inspired by Disney characters that are appropriate for theme parks.

    Character to bound:
    - Name: {{ character.name }}
    - Movie: {{ character.movie }}
    - Category: {{ character.category }}
    - Primary Colors: {{ character.primaryColors }}
    - Secondary Colors: {{ character.secondaryColors }}
    - Aesthetic: {{ character.aestheticKeywords }}

    User Preferences:
    - Budget: {{ preferences.budget }}
    - Style: {{ preferences.style }}
    - Weather: {{ preferences.climateConsiderations }}

    User's existing wardrobe items:
    {{ preferences.existingWardrobe }}

    Create an outfit suggestion that:
    1. Captures the essence of the character through color and style
    2. Uses everyday clothing (no costumes)
    3. Is practical for walking around a theme park
    4. Incorporates items from the user's wardrobe when possible
    5. Fits the user's budget and style preferences

    {{ ctx.output_format }}
  "#
}

function MatchCharacterByColors(colors: string[]) -> Character[] {
  client Gemini
  prompt #"
    You are a Disney character expert. Given these colors from someone's wardrobe,
    suggest Disney characters that would work well for a Disneybound outfit.

    Colors available: {{ colors }}

    Suggest 3-5 Disney characters whose color palettes match well with these colors.
    For each character, explain why the color match works.

    {{ ctx.output_format }}
  "#
}

function GenerateColorPalette(character: Character) -> string[] {
  client Gemini
  prompt #"
    You are a color expert specializing in Disney character aesthetics.

    For the character {{ character.name }} from {{ character.movie }}:
    - Category: {{ character.category }}
    - Known primary colors: {{ character.primaryColors }}

    Generate a complete Disneybound color palette with hex codes.
    Include:
    - 2-3 primary colors (the most recognizable character colors)
    - 2-3 secondary/accent colors
    - 1-2 neutral colors that work well with the palette

    Return as an array of hex color codes.

    {{ ctx.output_format }}
  "#
}

function DescribeOutfit(items: ClothingItem[]) -> string {
  client Gemini
  prompt #"
    Write a short, engaging description of this Disneybound outfit for sharing on social media.
    Keep it under 280 characters.

    Outfit items:
    {{ items }}

    The description should:
    - Mention the character inspiration if evident
    - Highlight key pieces
    - Be fun and enthusiastic
    - Include relevant hashtags

    {{ ctx.output_format }}
  "#
}

// =============================================================================
// TEST CASES
// =============================================================================

test SuggestOutfit {
  functions [SuggestOutfit]
  args {
    character {
      name "Cinderella"
      movie "Cinderella"
      category "Princess"
      primaryColors ["light blue", "silver"]
      secondaryColors ["white", "pink"]
      aestheticKeywords ["elegant", "dreamy", "romantic"]
    }
    preferences {
      budget "medium"
      style "dressy"
      climateConsiderations "hot"
      existingWardrobe [
        {
          itemType "top"
          description "Light blue blouse"
          color "light blue"
        }
      ]
    }
  }
}
