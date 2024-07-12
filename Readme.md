# Dungeon Ganstas - Old school text adventure

This project is a flexible text adventure game engine written in Ruby. It allows you to create interactive, text-based adventure games with rooms, items, monsters, and various commands.

## Features

- Dynamic room navigation
- Item management (picking up and dropping items)
- Combat system with monsters
- Character stats (health, strength, defense)
- Customizable game data using YAML files
- Extensible command system
- Inventory management
- Simple natural language processing for game commands

## Getting Started

### Prerequisites

- Ruby (version 2.7 or higher recommended)
- Bundler

### Installation

1. Clone this repository:

```
git clone https://github.com/yourusername/ruby-text-adventure.git
```

1.1. Change directory
```
cd ruby-text-adventure
```

2. Install dependencies:

```
bundle install
```

### Running the Game

To start the game, run:

```
ruby game.rb
```

Follow the on-screen prompts to navigate through the adventure.

### Customizing the Game

You can customize the game by editing the `game_data.yml` file in the `data` directory. This file defines rooms, items, monsters, and available commands.

## Project Structure

- `engine.rb`: The main game engine
- `character.rb`: Character class for managing player stats
- `console_output.rb`: Utility for console output
- `game.rb`: The main game loop
- `data/game_data.yml`: YAML file containing game data
- `spec/`: Directory containing test files

## Running Tests

To run the test suite:

```
rspec
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

lol
