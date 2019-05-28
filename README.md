# BTCPoW

Bitcoin style Proof of Work lib written in Crystal

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     btcpow:
       github: cocol-project/btcpow
   ```

2. Run `shards install`

## Usage

```crystal
require "btcpow"
```

#### Mining
```crystal
BTCPoW.mine(difficulty: "1d00ffff", for: "my_block_data")
```

#### Calculate target based on difficulty bits
```crystal
BTCPoW::Utils.calculate_target(from: "1d00ffff")
```

## Contributing

1. Fork it (<https://github.com/cocol-project/btcpow/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Cristian Șerb](https://github.com/cserb) - creator and maintainer
