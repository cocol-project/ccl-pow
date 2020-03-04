# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at # http://mozilla.org/MPL/2.0/

require "./spec_helper"

describe CCL::Pow do
  it "mines correctly" do
    cocol = CCL::Pow.mine(difficulty: CCL::Pow::Utils::MIN_NBITS, for: "cocol")
    cocol.nonce.should be > 1
    BigInt.new(cocol.hash, 16).should be < CCL::Pow::Utils::MIN_TARGET
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

  it "calculates nbits from target" do
    nbits = CCL::Pow::Utils.calculate_nbits(from: BigInt.new("26959535291011309493156476344723991336010898738574164086137773096960"))
    nbits.should eq("1d00ffff")
  end

  context "retarget" do
    it "finds new target" do
      new_target_nbits = CCL::Pow::Utils.retarget(
        # we test for 1 second less then wanted timespan
        start_time: (Time.utc.to_unix - 59).to_f64,
        end_time: Time.utc.to_unix.to_f64,
        wanted_timespan: 60_f64,
        current_target: CCL::Pow::Utils::MIN_TARGET
      )
      new_target = CCL::Pow::Utils.calculate_target(new_target_nbits)
      new_target.should be < CCL::Pow::Utils::MIN_TARGET
    end

    it "finds new target" do
      new_target_nbits = CCL::Pow::Utils.retarget(
        # we test for 1 second more then timespan
        start_time: (Time.utc.to_unix - 61).to_f64,
        end_time: Time.utc.to_unix.to_f64,
        wanted_timespan: 60_f64,
        current_target: CCL::Pow::Utils::MIN_TARGET
      )
      new_target_nbits.should eq CCL::Pow::Utils::MIN_NBITS
    end

    it "returns min nbits when start & end equal" do
      time = Time.utc.to_unix.to_f64
      new_target = CCL::Pow::Utils.retarget(
        start_time: time,
        end_time: time,
        wanted_timespan: 60_f64,
        current_target: CCL::Pow::Utils.calculate_target("1e38ae39")
      )
      new_target.should eq(CCL::Pow::Utils::MIN_NBITS)
    end
  end
end
