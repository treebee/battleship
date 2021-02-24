defmodule :"Elixir.Battleship.Repo.Migrations.Ensure max 2 players" do
  use Ecto.Migration

  def change do
    execute "
    CREATE OR REPLACE FUNCTION check_max_participants() RETURNS trigger AS $$
    DECLARE
	  player_count INTEGER := 0;
	  BEGIN
      IF TG_OP = 'INSERT' THEN
        LOCK TABLE participants IN EXCLUSIVE MODE;

        SELECT INTO player_count COUNT(*)
        FROM participants
        WHERE game_id = NEW.game_id;

        IF player_count >= 2 THEN
          RAISE EXCEPTION 'A Game cannot have more than 2 participants!';
        END IF;
      END IF;

      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    "
    execute "
    CREATE TRIGGER enforce_max_participants
      BEFORE INSERT ON participants
      FOR EACH ROW EXECUTE PROCEDURE check_max_participants();
    "
  end
end
