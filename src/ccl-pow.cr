require "big"
require "openssl"

# A Bitcoin style Proof of Work library for Crystal
# Mostly inspired by @aantonop's proof of work example
# https://github.com/bitcoinbook/bitcoinbook/blob/develop/code/proof-of-work-example.py
module CCL::Pow
  extend self

  alias InputData = String
  alias BlockHash = String

  record Work,
    nonce : UInt64,
    hash : BlockHash

  # Returns the nonce and the hash found for the given data input and difficulty
  #
  # ```
  # CCL::Pow.mine(difficulty: "1d00ffff", for: "my_blockchain_data")
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

    MIN_TARGET = BigInt.new("1000000000000000000000000000000000000000000000000000000000000000", 16)
    MIN_NBITS  = "20100000"

    alias NBits = String

    # Returns the hash for `nonce` + `data`
    #
    # ```
    # CCL::Pow::Utils.calculate_hash(nonce: 20151213_u64, data: "cocol") # => "5906039dfa0262343155216f0d73135d30fd48a0d4543c61d27169db12736d3a"
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
    # CCL::Pow::Utils.calculate_target(from: "1d00ffff") # => 26959535291011309493156476344723991336010898738574164086137773096960
    # ```
    def calculate_target(from nbits : String) : BigInt
      exponent = BigInt.new(nbits[0..1], 16)
      coefficient = BigInt.new(nbits[2..7], 16)

      coefficient * (BigInt.new(2) ** (BigInt.new(8)*(exponent - BigInt.new(3))))
    end

    # Returns the target as nbits from a given numerical target
    #
    # ```
    # CCL::Pow::Utils.calculate_nbits(from: BigInt.new("26959535291011309493156476344723991336010898738574164086137773096960")) # => "1d00ffff"
    # ```
    def calculate_nbits(from target : BigInt) : NBits
      h_target = target.to_s(16)
      first_digit = h_target[0..1].to_i(16)
      if first_digit > 127
        h_target = "00#{h_target}"
      end
      size = (h_target.bytesize/2).to_i32
      "#{size.to_s(16)}#{h_target[0..5]}"
    end

    # Returns the retargeted difficulty based on the timestamp of a given block
    # and the timespan in minutes.
    #
    # Assuming you want retarget for the last minute in which you targeted 12 blocks
    # you would pass the timestamp of the `current_block - 12` and 60 seconds as wanted_timepan
    #
    # ```
    # CCL::Pow::Utils.retarget(
    #   start_time: 1559306286_f64,
    #   end_time: 1559306286_f64,
    #   wanted_timespan: 60_f64,
    #   current_target: CCL::Pow::Utils.calculate_target("1e38ae39")
    # ) # => "1e00b560"
    # ```
    def retarget(start_time : Float64,
                 end_time : Float64,
                 wanted_timespan : Float64,
                 current_target : BigInt) : NBits
      passed_time = end_time - start_time

      new_num_target = current_target * BigFloat.new(passed_time / wanted_timespan)
      calculate_nbits from: BigInt.new(new_num_target)
    end
  end
end
