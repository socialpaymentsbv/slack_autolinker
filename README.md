# SlackAutolinker

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

A Slack bot that autolinks things.

## Live testing

_(for @socialpaymentsbv developers)_

For staging environment, just DM @clippy-stag in https://clubcollect.slack.com. But first make sure that the staging app 
has at least one dyno unit setup.
Production is already integrated with related channels. There you can DM @clippy. 

## Configuration

```json
{
  "be": "socialpaymentsbv/billing-engine",
  "bee": "socialpaymentsbv/billing-engine-exports",
  "si": "socialpaymentsbv/support-issues",
  "cb": "socialpaymentsbv/clubbase.io",
  "cbio": "socialpaymentsbv/clubbase.io",
  "cblisa": "socialpaymentsbv/clubbase",
  "etmt": "socialpaymentsbv/etmt",
  "wio": "socialpaymentsbv/welcoming.io",
  "purpose": "socialpaymentsbv/purpose",
  "cio": "socialpaymentsbv/charging.io",
  "p": "socialpaymentsbv/purpose",
  "pio": "socialpaymentsbv/purpose",
  "bot": "socialpaymentsbv/slack_autolinker",
  "pio-elixir": "socialpaymentsbv/purpose-elixir-client",
  "pio-ruby": "socialpaymentsbv/purpose-ruby-client",
  "fsm": "socialpaymentsbv/fuzzy_smoke_machine",
  "wwwcc": "socialpaymentsbv/www-clubcollect-com",
  "ecto": "elixir-ecto/ecto",
  "qb": "socialpaymentsbv/query_builder",
  "wiki": "socialpaymentsbv/wiki"
}
```




## Copyright and License

Copyright (c) 2017-2022 NLCollect B.V.
The source code is licensed under [The MIT License (MIT)](LICENSE.md)
