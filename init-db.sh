#!/bin/bash

wget --no-check-certificate http://illarion.org/media/localserver/db_dumps.php?request=schema -O devserver_schema.dump --quiet
wget --no-check-certificate http://illarion.org/media/localserver/db_dumps.php?request=content -O devserver_content.dump --quiet
wget --no-check-certificate http://illarion.org/media/localserver/db_dumps.php?request=accounts_schema -O accounts_schema.dump --quiet
wget --no-check-certificate http://illarion.org/media/localserver/db_dumps.php?request=accounts_content -O accounts_content.dump --quiet
wget --no-check-certificate http://illarion.org/media/localserver/db_dumps.php?request=homepage_schema -O homepage_schema.dump --quiet

psql -v -d illarion -U illarion <<-EOSQL
    CREATE USER homepage;
    GRANT ALL PRIVILEGES ON DATABASE illarion TO homepage;
    ALTER USER homepage WITH SUPERUSER;
EOSQL

pg_restore -d illarion -Fc -O -x -1 -U illarion accounts_schema.dump > /dev/null
psql illarion -1 -U illarion -f devserver_schema.dump > /dev/null
pg_restore -d illarion -Fc -O -x -1 -U illarion devserver_content.dump > /dev/null
pg_restore -d illarion -Fc -O -x -1 -U illarion accounts_content.dump > /dev/null

psql -U illarion -c "ALTER SCHEMA devserver RENAME TO illarionserver;" illarion > /dev/null

pg_restore -d illarion -Fc -O -x -1 -U homepage homepage_schema.dump > /dev/null

