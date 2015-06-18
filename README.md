# hubot-slack

This is a [Hubot](http://hubot.github.com/) adapter to use with [Ship](https://ship.hn).

## Getting Started

#### Creating a new bot

- `npm install -g hubot coffee-script yo generator-hubot`
- `mkdir -p /path/to/hubot`
- `cd /path/to/hubot`
- `yo hubot`
- `npm install hubot-ship --save`
- Initialize git and make your initial commit
- Check out the [hubot docs](https://github.com/github/hubot/tree/master/docs) for further guidance on how to build your bot

#### Testing your bot locally

- `VERTX_SERVER_ADDRESS=http://localhost:3333/eventbus ./bin/hubot --adapter slack`

## Configuration

This adapter uses the following environment variables:

 - `VERTX_SERVER_ADDRESS` - this is the vertx server address where vertx is communicating with ship.