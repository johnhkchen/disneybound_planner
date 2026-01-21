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

class ColorInfo {
  hex string @description("Hex color code like #FFD700")
  name string @description("Human readable color name like 'Bright Yellow'")
  usage string @description("Where this color appears, e.g. 'Primary body color'")
}

class CharacterSearchResult {
  found bool @description("Whether a matching Disney character was found")
  name string @description("Character's name")
  movie string @description("Film or show the character is from, with year if known")
  description string @description("Brief description of the character (1-2 sentences)")
  category string @description("Princess, Villain, Pixar, Sidekick, Classic, etc.")
  colors ColorInfo[] @description("3-5 signature colors for this character")
  notFoundMessage string? @description("Helpful message if character wasn't found")
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

function SearchCharacter(query: string) -> CharacterSearchResult {
  client Gemini
  prompt #"
    You are a Disney character expert helping users find characters for Disneybounding
    (creating everyday outfits inspired by Disney characters).

    User's search query: "{{ query }}"

    Identify the Disney character the user is looking for. Handle:
    - Exact names ("Flounder")
    - Partial names ("the fish from little mermaid")
    - Descriptions ("Ariel's yellow fish friend")
    - Misspellings and variations

    If you identify a Disney character:
    - Set found to true
    - Provide the character's full name
    - Include the film/show name with year
    - Write a brief 1-2 sentence description
    - Categorize them (Princess, Villain, Sidekick, Pixar, Classic, Marvel, Star Wars, etc.)
    - List 3-5 signature colors with hex codes that someone could use for Disneybounding

    If you cannot identify a Disney character:
    - Set found to false
    - Provide a helpful notFoundMessage suggesting how to refine the search

    For the colors, focus on the character's most recognizable visual elements
    that would be useful for creating a Disneybound outfit.

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

test SearchCharacterFlounder {
  functions [SearchCharacter]
  args {
    query "Flounder"
  }
}

test SearchCharacterFuzzy {
  functions [SearchCharacter]
  args {
    query "the fish from little mermaid"
  }
}

test SearchCharacterNotFound {
  functions [SearchCharacter]
  args {
    query "asdfghjkl random gibberish"
  }
}
