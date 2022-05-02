class HC_SR04
  require 'bundler/setup'
  require 'google/cloud/firestore'
  Bundler.require

  INPUT_PIN_NUM = 18
  OUTPUT_PIN_NUM = 27
  PASSING_DISTANCE = 30

  def initialize
    RPi::GPIO.set_numbering :bcm
    RPi::GPIO.setup INPUT_PIN_NUM, as: :input
    RPi::GPIO.setup OUTPUT_PIN_NUM, as: :output
    RPi::GPIO.set_warnings(false)
  end

  def exec
    i = 0
    while i < 20
      pulse_in ? workout : (puts 'まだやれるぞ！')
      sleep(2)
      i += 1
    end
    puts "おつかれさまでした"
  end

  private

  def pulse_in
    RPi::GPIO.set_high(OUTPUT_PIN_NUM)
    start_time = Time.now.to_f
    sleep(0.00001)
    RPi::GPIO.set_low(OUTPUT_PIN_NUM)
    RPi::GPIO.wait_for_edge INPUT_PIN_NUM, :falling, timeout: 5000
    end_time = Time.now.to_f
    (end_time - start_time) * 10000 < PASSING_DISTANCE
  end

  Signal.trap(:INT) do
    puts 'Interrupt!'
    RPi::GPIO.reset
    exit
  end

  def workout
    firestore = Google::Cloud::Firestore.new(
      project_id: "my-fukkin-counter",
      credentials: "./my-fukkin-counter-5e94742d8099.json"
    )
    doc_ref = firestore.col("workouts").doc
    doc_ref.set({ ab_roll: true })
    puts 'いいぞその調子!'
  end
end

HC_SR04.new.exec
