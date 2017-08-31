# bikestalker

Uses Citibike's GBFS API to collect data on station bike and dock availability.

## Getting Started

You'll need a postgres database.  Set your postgres connection string:

```
export BIKESTALKER_PG_URL=postgres://user:password@host:port/database
```

Make sure you have Ruby installed. Then install dependencies:

```
bundle install
```

Start collecting data!  This will create the necessary tables if you don't already have them, populate the stations, and pull down station info.

```
ruby get_stations.rb
```

## Set up cron

Use the `run.sh` script to log output to `run.log`.

```
*/5 * * * * /home/gordon/dev/bikestalker/run.sh
```