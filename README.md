# Bookish [![Build Status](https://travis-ci.org/beccanelson/bookish.svg?branch=master)](https://travis-ci.org/beccanelson/bookish)
### Where is that book?

This is a book-tracking application built with Elixir and Phoenix

[Check it out on Heroku!](https://bookish-library.herokuapp.com)

## Dependencies:

+ [Elixir](http://elixir-lang.org/install.html)
+ [Phoenix](http://www.phoenixframework.org/docs/installation)

If you do not have either of these currently installed, follow the links for installation instructions.

## To run locally: 

1. Clone this repository
2. In the root directory:
```
mix deps.get
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs
```
This application uses [Ueberauth](https://github.com/ueberauth/ueberauth) for authentication through Slack. In order to authenticate locally:

1. Create a file called `dev.secret.exs` in `config/`
2. Generate a Client ID and Client Secret through [Slack](https://api.slack.com/docs/sign-in-with-slack#create_slack_app)
3. Under OAuth & Permissions (on Slack) add a Redirect URL. ex: `http://localhost:4000/auth/slack/callback`
4. Add your secret keys to `dev.secret.exs`. Your file should look like this:
```
use Mix.Config

config :ueberauth, Ueberauth.Strategy.Slack.OAuth, 
  client_id: "CLIENT ID",
  client_secret: "CLIENT SECRET"
```
Start the server:
```
mix phoenix.server
```
Open [http://localhost:4000](http://localhost:4000) in your browser

## To run tests:

```
mix test
```
