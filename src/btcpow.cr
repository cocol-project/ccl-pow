require "big"
require "openssl"

# A Bitcoin style Proof of Work library for Crystal
# Mostly inspired by @aantonop's proof of work example
# https://github.com/bitcoinbook/bitcoinbook/blob/develop/code/proof-of-work-example.py
module BTCPoW
  extend self

  alias InputData = String
  alias BlockHash = String

  record Work,
    nonce : UInt64,
    hash : BlockHash

  # Returns the nonce and the hash found for the given data input and difficulty
  #
  # ```
  # BTCPoW.mine(difficulty: "1d00ffff", for: "my_blockchain_data")
  # ```
  def mine(difficulty nbits : String, for input_data : InputData) : Work
    target = Utils.calculate_target(from: nbits)

    (0_u64..UInt64::MAX).each do |nonce|
      hash = Utils.calculate_hash(nonce, data: input_data)
      if BigInt.new(hash, 16) < target
        return Work.new(nonce: nonce, hash: hash)
      end
    end

    raise "Canary dead"
  end

  module Utils
    extend self

    # Returns the hash for `nonce` + `data`
    #
    # ```
    # BTCPoW::Utils.calculate_hash(nonce: 20151213_u64, data: "cocol") # => "5906039dfa0262343155216f0d73135d30fd48a0d4543c61d27169db12736d3a"
    # ```
    def calculate_hash(nonce : UInt64, data : String) : BlockHash
      sha = OpenSSL::Digest.new("SHA256")
      sha.update("#{nonce}#{data}")
      sha.hexdigest
    end

    # Returns the numerical target threshold based on the given difficulty
    #
    # Find out more about it here
    # https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch10.asciidoc#target-representation
    #
    # ```
    # BTCPoW::Utils.calculate_target(from: "1d00ffff") # => 26959535291011309493156476344723991336010898738574164086137773096960
    # ```
    def calculate_target(from nbits : String) : BigInt
      exponent = BigInt.new(nbits[0..1], 16)
      coefficient = BigInt.new(nbits[2..7], 16)

      coefficient * (BigInt.new(2) ** (BigInt.new(8)*(exponent - BigInt.new(3))))
    end
  end
end
