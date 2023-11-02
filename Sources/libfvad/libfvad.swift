// The Swift Programming Language
// https://docs.swift.org/swift-book
import clibfvad

public enum VadError: Error {
    case invalidSampleRate
    case invalidMode
    case invalidFrameLength
}

public enum VadOperatingMode: Int32 {
    case quality = 0
    case lowBitrate = 1
    case aggressive = 2
    case veryAggressive = 3
}

public enum VadVoiceActivity: Int32 {
    case activeVoice = 1
    case nonActiveVoice = 0
}
    
public class VoiceActivityDetector {
    private let vad = fvad_new()
    
    public init() {
        
    }
    
    /*
     * Changes the VAD operating ("aggressiveness") mode of a VAD instance.
     *
     * A more aggressive (higher mode) VAD is more restrictive in reporting speech.
     * Put in other words the probability of being speech when the VAD returns 1 is
     * increased with increasing mode. As a consequence also the missed detection
     * rate goes up.
     *
     * Valid modes are 0 ("quality"), 1 ("low bitrate"), 2 ("aggressive"), and 3
     * ("very aggressive"). The default mode is 0.
     *
     * Returns 0 on success, or -1 if the specified mode is invalid.
     */
    public func setMode(mode: VadOperatingMode) throws {
        if fvad_set_mode(vad, mode.rawValue) != 0 {
            throw VadError.invalidMode
        }
    }
    
    /*
     * Sets the input sample rate in Hz for a VAD instance.
     *
     * Valid values are 8000, 16000, 32000 and 48000. The default is 8000. Note
     * that internally all processing will be done 8000 Hz; input data in higher
     * sample rates will just be downsampled first.
     *
     * Returns 0 on success, or -1 if the passed value is invalid.
     */
    public func setSampleRate(sampleRate: Int) throws {
        if fvad_set_sample_rate(vad, Int32(sampleRate)) != 0 {
            throw VadError.invalidSampleRate
        }
    }
    
    /*
     * Calculates a VAD decision for an audio frame.
     *
     * `frame` is an array of `length` signed 16-bit samples. Only frames with a
     * length of 10, 20 or 30 ms are supported, so for example at 8 kHz, `length`
     * must be either 80, 160 or 240.
     *
     * Returns              : 1 - (active voice),
     *                        0 - (non-active Voice),
     *                       -1 - (invalid frame length).
     */
    public func process(frame: UnsafePointer<Int16>, length: Int) throws -> VadVoiceActivity {
        let ret = fvad_process(vad, frame, length)
        if ret == -1 {
            throw VadError.invalidFrameLength
        }
        return VadVoiceActivity(rawValue: ret)!
    }
    
    public func reset() {
        fvad_reset(vad)
    }
    
    deinit {
        fvad_free(vad)
    }
}
