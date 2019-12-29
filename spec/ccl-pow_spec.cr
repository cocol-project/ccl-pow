require "./spec_helper"

describe CCL::Pow do
  it "mines correctly" do
    cocol = CCL::Pow.mine(difficulty: "20100000", for: "cocol")
    cocol.nonce.should be > 1
    BigInt.new(cocol.hash, 16).should be < BigInt.new("1000000000000000000000000000000000000000000000000000000000000000", 16)
  end
end

describe CCL::Pow::Utils do
  it "calculates hash correctly" do
    hash = CCL::Pow::Utils.calculate_hash(nonce: 20151213_u64, data: "cocol")
    hash.should eq("5906039dfa0262343155216f0d73135d30fd48a0d4543c61d27169db12736d3a")
  end

  it "calculates target correctly" do
    # difficulty 1 from the genesis block translates to "1d00ffff"
    # and the correct numerical target is 26959535291011309493156476344723991336010898738574164086137773096960
    target = CCL::Pow::Utils.calculate_target(from: "1d00ffff")
    target.should eq(BigInt.new("26959535291011309493156476344723991336010898738574164086137773096960", 10))
  end

  # Testing for obvious bugs
  it "finds new target" do
    new_target = CCL::Pow::Utils.retarget(
      start_time: (Time.utc.to_unix - 12).to_f64, # we test for 12 seconds
      end_time: Time.utc.to_unix.to_f64,
      wanted_timespan: 60_f64, # we actually want it to take 1 minute
      current_target: CCL::Pow::Utils.calculate_target("1e38ae39")
    )
    new_target.should eq("1e00b560")
  end

  it "calculates nbits from target" do
    nbits = CCL::Pow::Utils.calculate_nbits(from: BigInt.new("26959535291011309493156476344723991336010898738574164086137773096960"))
    nbits.should eq("1d00ffff")
  end

  # it "retargets" do
  #   diff = "1e38ae39"
  #   start_time = Time.now
  #   pp "-- Start: #{start_time}"
  #   (1..30).each do |i|
  #     block = CCL::Pow.mine(difficulty: diff, for: "TestMe#{Time.now}#{Random::Secure.hex}")
  #     pp "#{i} #{block.hash} #{block.nonce}"
  #     # sleep 0.3
  #   end
  #   end_time = Time.now
  #   pp "-- End: #{end_time}"

  #   retarget = CCL::Pow::Utils.retarget(
  #     start_time: start_time.to_unix,
  #     end_time: end_time.to_unix,
  #     wanted_timespan: 30_u32,
  #     current_target: CCL::Pow::Utils.calculate_target(diff)
  #   )
  #   pp "---- RETARGET: #{retarget}"
  # end
end
