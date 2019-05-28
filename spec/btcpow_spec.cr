require "./spec_helper"

describe BTCPoW do
  it "mines correctly" do
    cocol = BTCPoW.mine(difficulty: "20100000", for: "cocol")
    cocol.nonce.should be > 1
    BigInt.new(cocol.hash, 16).should be < BigInt.new("1000000000000000000000000000000000000000000000000000000000000000", 16)
  end
end

describe BTCPoW::Utils do
  it "calculates hash correctly" do
    hash = BTCPoW::Utils.calculate_hash(nonce: 20151213_u64, data: "cocol")
    hash.should eq("5906039dfa0262343155216f0d73135d30fd48a0d4543c61d27169db12736d3a")
  end

  # There is a possible bug. The type of `target` is returned as `FBigInt`
  # which is clearly wrong. Until solution is found or or in case of bug
  # it's fixed this is a pending test
  pending "calculates target correctly" do
    # difficulty 1 from the genesis block translates to "1d00ffff"
    # and the correct numerical target is 26959535291011309493156476344723991336010898738574164086137773096960
    target = BTCPoW::Utils.calculate_target(from: "1d00ffff")
    target.should eq(BigInt.new("26959535291011309493156476344723991336010898738574164086137773096960", 10))
  end
end
