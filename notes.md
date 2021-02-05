# Database Schema

games

- id(uuid): primary_key
-

participants

- username(string)
- game_id(uuid): foreign_key(games.id)
- shots(jsonb): ({"1": (3, 4), "2": (6, 7)})
- ships(jsonb): ([{"name": "destroyer", "position": [3, 4], "direction": "x"}])
  - use embeds_many

# Design

When ships placed and Player clicks 'ready':

- store 'ships' to participants.ships
- when both players ready: broadcast 'start game' to 'game:<game-id>'
  -> handle_event('start game') -> live navigation
