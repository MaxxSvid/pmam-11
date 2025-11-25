import Foundation


typealias Bytes = [UInt8]
func u16(_ v: UInt16) -> Bytes { return [UInt8(v >> 8), UInt8(v & 0xFF)] }
func u32(_ v: UInt32) -> Bytes { return [UInt8((v >> 24) & 0xFF), UInt8((v >> 16) & 0xFF), UInt8((v >> 8) & 0xFF), UInt8(v & 0xFF)] }
func vlq(_ value: Int) -> Bytes {
    var buffer: [UInt8] = []
    var val = value
    var bytes: [UInt8] = []
    repeat {
        bytes.append(UInt8(val & 0x7F))
        val >>= 7
    } while val > 0
    for i in (0..<bytes.count).reversed() {
        var b = bytes[i]
        if i != 0 { b |= 0x80 }
        buffer.append(b)
    }
    return buffer
}
extension Array {
    func sample() -> Element? { return isEmpty ? nil : self[Int.random(in: 0..<count)] }
}
func clamp<T: Comparable>(_ v: T, _ a: T, _ b: T) -> T { return min(max(v, a), b) }


struct Note {
    let midi: Int
    var name: String {
        let names = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
        let pitch = midi % 12
        let octave = midi / 12 - 1
        return "\(names[pitch])\(octave)"
    }
}

enum ScaleType: String, CaseIterable {
    case major, minorNatural, minorHarmonic, majorPentatonic, minorPentatonic
    var intervals: [Int] {
        switch self {
        case .major: return [0,2,4,5,7,9,11]
        case .minorNatural: return [0,2,3,5,7,8,10]
        case .minorHarmonic: return [0,2,3,5,7,8,11]
        case .majorPentatonic: return [0,2,4,7,9]
        case .minorPentatonic: return [0,3,5,7,10]
        }
    }
}

struct Key {
    let rootMidi: Int
    let scale: ScaleType
    func noteAt(degree: Int, octaveShift: Int = 0) -> Note {
        let ints = scale.intervals
        let degreeWrapped = ((degree % ints.count) + ints.count) % ints.count
        let octaveAdd = degree / ints.count
        let semitone = ints[degreeWrapped] + 12*(octaveShift + octaveAdd)
        return Note(midi: rootMidi + semitone)
    }
    var name: String {
        let names = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
        return "\(names[(rootMidi%12)]) \(scale.rawValue)"
    }
}

enum ProgressionPreset {
    case classic, pop, jazzII_V_I, blues12, random
}
struct Chord {
    let rootMidi: Int
    let intervals: [Int]
    func notes(octaveShift: Int = 0) -> [Note] {
        return intervals.map { Note(midi: rootMidi + $0 + 12*octaveShift) }
    }
    func name() -> String {
        let roots = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
        let r = roots[(rootMidi % 12)]
        if intervals == [0,4,7] { return "\(r)" }
        if intervals == [0,3,7] { return "\(r)m" }
        if intervals == [0,4,7,11] { return "\(r)maj7" }
        if intervals == [0,3,7,10] { return "\(r)m7" }
        if intervals == [0,4,7,10] { return "\(r)7" }
        return r
    }
}

struct HarmonyEngine {
    let key: Key
    func triad(rootDegree: Int, type: String = "auto", octave: Int = 0) -> Chord {
        let root = key.noteAt(degree: rootDegree, octaveShift: octave)
        switch type {
        case "major": return Chord(rootMidi: root.midi, intervals: [0,4,7])
        case "minor": return Chord(rootMidi: root.midi, intervals: [0,3,7])
        case "maj7": return Chord(rootMidi: root.midi, intervals: [0,4,7,11])
        case "min7": return Chord(rootMidi: root.midi, intervals: [0,3,7,10])
        case "dom7": return Chord(rootMidi: root.midi, intervals: [0,4,7,10])
        default:
            if key.scale == .major {
                switch (rootDegree % key.scale.intervals.count) {
                case 0: return Chord(rootMidi: root.midi, intervals: [0,4,7])
                case 1: return Chord(rootMidi: root.midi, intervals: [0,3,7])
                case 2: return Chord(rootMidi: root.midi, intervals: [0,3,7])
                case 3: return Chord(rootMidi: root.midi, intervals: [0,4,7])
                case 4: return Chord(rootMidi: root.midi, intervals: [0,4,7])
                case 5: return Chord(rootMidi: root.midi, intervals: [0,3,7])
                default: return Chord(rootMidi: root.midi, intervals: [0,3,6])
                }
            } else {
                switch (rootDegree % key.scale.intervals.count) {
                case 0: return Chord(rootMidi: root.midi, intervals: [0,3,7])
                case 1: return Chord(rootMidi: root.midi, intervals: [0,4,7])
                default: return Chord(rootMidi: root.midi, intervals: [0,3,7])
                }
            }
        }
    }
    func progression(preset: ProgressionPreset, bars: Int = 8) -> [Chord] {
        var out: [Chord] = []
        let seqCount = max(1, key.scale.intervals.count)
        switch preset {
        case .classic:
            let seq = [0,3,4,0]
            for _ in 0..<(bars/seq.count) { out += seq.map { triad(rootDegree: $0) } }
        case .pop:
            let seq = [0,4,5,3]
            for _ in 0..<(bars/seq.count) { out += seq.map { triad(rootDegree: $0) } }
        case .jazzII_V_I:
            for _ in 0..<(max(1,bars/3)) {
                out.append(triad(rootDegree: 1, type: "min7"))
                out.append(triad(rootDegree: 4, type: "dom7"))
                out.append(triad(rootDegree: 0, type: "maj7"))
            }
        case .blues12:
            let I = triad(rootDegree: 0)
            let IV = triad(rootDegree: 3)
            let V = triad(rootDegree: 4)
            let seq: [Chord] = [I,I,I,I,IV,IV,I,I,V,IV,I,I]
            out = seq
        case .random:
            for _ in 0..<bars {
                let deg = Int.random(in: 0..<seqCount)
                out.append(triad(rootDegree: deg))
            }
        }
        if out.isEmpty {
            for _ in 0..<bars { out.append(triad(rootDegree: 0)) }
        }
        if out.count > bars { out = Array(out.prefix(bars)) }
        while out.count < bars { out.append(triad(rootDegree: 0)) }
        return out
    }
}


enum Duration {
    case whole, half, quarter, eighth, sixteenth, triplet
    var quarters: Double {
        switch self {
        case .whole: return 4.0
        case .half: return 2.0
        case .quarter: return 1.0
        case .eighth: return 0.5
        case .sixteenth: return 0.25
        case .triplet: return 1.0/3.0
        }
    }
}
struct RhythmPattern {
    let sequence: [Duration]
    var totalQuarters: Double { sequence.map{ $0.quarters }.reduce(0, +) }
    static func simpleBars(barCount: Int, meter: Int = 4) -> [[Duration]] {
        var bars: [[Duration]] = []
        let variants: [[Duration]] = [
            [.quarter, .quarter, .quarter, .quarter],
            [.half, .quarter, .quarter],
            [.quarter, .quarter, .half],
            [.quarter, .eighth, .eighth, .quarter, .quarter],
            [.eighth, .eighth, .quarter, .quarter, .quarter]
        ]
        for _ in 0..<barCount { bars.append(variants.sample() ?? [.quarter, .quarter, .quarter, .quarter]) }
        return bars
    }
}


struct MelodyNote {
    let midi: Int
    let startQuarter: Double
    let durationQuarter: Double
}

class MelodyGenerator {
    let key: Key
    let harmony: [Chord]
    let bars: Int
    let meter: Int
    init(key: Key, harmony: [Chord], bars: Int = 8, meter: Int = 4) {
        self.key = key; self.harmony = harmony; self.bars = bars; self.meter = meter
    }
    func generateMelody(style: String = "classical", complexity: Double = 0.6) -> [MelodyNote] {
        var notes: [MelodyNote] = []
        var currentPitch = key.rootMidi
        for (i, chord) in harmony.enumerated() {
            let barStart = Double(i * meter)
            let durations = RhythmPattern.simpleBars(barCount: 1, meter: meter).first ?? [.quarter, .quarter, .quarter, .quarter]
            var beatOffset: Double = 0.0
            for d in durations {
                let chooseChordTone = Double.random(in: 0...1) < 0.7
                var pitch: Int
                if chooseChordTone {
                    let chordNotes = chord.notes(octaveShift: 0).map{ $0.midi }
                    pitch = chordNotes.sample() ?? chord.rootMidi
                    pitch += Int.random(in: -12...12)
                } else {
                    let degree = Int.random(in: 0..<key.scale.intervals.count)
                    pitch = key.noteAt(degree: degree).midi + Int.random(in: -12...12)
                }
                if Double.random(in: 0...1) < complexity {
                    let step = Int.random(in: -2...2)
                    pitch = currentPitch + step
                } else {
                    pitch += Int.random(in: -7...7)
                }
                pitch = clamp(pitch, 36, 84)
                notes.append(MelodyNote(midi: pitch, startQuarter: barStart + beatOffset, durationQuarter: d.quarters))
                currentPitch = pitch
                beatOffset += d.quarters
            }
        }
        return notes
    }
}


class MarkovMelodyGenerator {
    let key: Key
    let harmony: [Chord]
    let bars: Int
    let meter: Int
    var transition: [Int: [Int]] = [:] 
    init(key: Key, harmony: [Chord], bars: Int = 8, meter: Int = 4) {
        self.key = key; self.harmony = harmony; self.bars = bars; self.meter = meter
        buildSimpleModel()
    }
    private func buildSimpleModel() {
        let degrees = key.scale.intervals.count
        for d in 0..<degrees {
            var outs: [Int] = []
            outs += Array(repeating: d, count: 4)
            if d+1 < degrees { outs += Array(repeating: d+1, count: 3) }
            if d-1 >= 0 { outs += Array(repeating: d-1, count: 3) }
            if d+2 < degrees { outs += [d+2] }
            if d-2 >= 0 { outs += [d-2] }
            transition[d] = outs
        }
    }
    func generateMelody() -> [MelodyNote] {
        var notes: [MelodyNote] = []
        var currentDegree = 0
        for (i, _) in harmony.enumerated() {
            let barStart = Double(i * meter)
            let durations = RhythmPattern.simpleBars(barCount: 1, meter: meter).first ?? [.quarter, .quarter, .quarter, .quarter]
            var beat: Double = 0.0
            for d in durations {
                let nextChoices = transition[currentDegree] ?? [currentDegree]
                let next = nextChoices.sample() ?? currentDegree
                let pitch = key.noteAt(degree: next).midi + Int.random(in: -12...12)
                notes.append(MelodyNote(midi: clamp(pitch,36,84), startQuarter: barStart + beat, durationQuarter: d.quarters))
                currentDegree = next
                beat += d.quarters
            }
        }
        return notes
    }
}

class BassGenerator {
    let key: Key
    init(key: Key) { self.key = key }
    func generateBass(harmony: [Chord]) -> [MelodyNote] {
        var out: [MelodyNote] = []
        for (i, chord) in harmony.enumerated() {
            let start = Double(i * 4)
            let base = chord.rootMidi - 12
            out.append(MelodyNote(midi: base, startQuarter: start, durationQuarter: 1.0))
            out.append(MelodyNote(midi: base, startQuarter: start + 1.0, durationQuarter: 1.0))
            out.append(MelodyNote(midi: base, startQuarter: start + 2.0, durationQuarter: 1.0))
            out.append(MelodyNote(midi: base, startQuarter: start + 3.0, durationQuarter: 1.0))
        }
        return out
    }
}

class ChordArpGenerator {
    func generateArpeggio(harmony: [Chord]) -> [MelodyNote] {
        var notes: [MelodyNote] = []
        for (i,ch) in harmony.enumerated() {
            let barStart = Double(i*4)
            let chordNotes = ch.notes(octaveShift: 0).map{ $0.midi }
            for beat in 0..<4 {
                let pitch = chordNotes[beat % chordNotes.count] + 12
                notes.append(MelodyNote(midi: pitch, startQuarter: barStart + Double(beat), durationQuarter: 1.0))
            }
        }
        return notes
    }
}

struct DrumHit {
    let midi: Int
    let startQuarter: Double
    let durationQuarter: Double
}
class DrumGenerator {
    func generatePattern(bars: Int) -> [DrumHit] {
        var out: [DrumHit] = []
        for b in 0..<bars {
            let base = Double(b * 4)
            out.append(DrumHit(midi: 36, startQuarter: base + 0.0, durationQuarter: 0.5)) 
            out.append(DrumHit(midi: 36, startQuarter: base + 2.0, durationQuarter: 0.5))
            out.append(DrumHit(midi: 38, startQuarter: base + 1.0, durationQuarter: 0.5)) 
            out.append(DrumHit(midi: 38, startQuarter: base + 3.0, durationQuarter: 0.5))
            for i in 0..<8 { out.append(DrumHit(midi: 42, startQuarter: base + Double(i)*0.5, durationQuarter: 0.25)) } 
            if Bool.random() { out.append(DrumHit(midi: 46, startQuarter: base + 1.5, durationQuarter: 0.5)) }
        }
        return out
    }
}


class MIDIWriter {
    let ticksPerQuarter: UInt16 = 480
    var tempoBPM: Int = 120
    var humanizeTimingMs: Int = 20 // +/- ms
    var humanizeVelocity: Int = 10 // +/- velocity
    init(tempoBPM: Int = 120, humanizeTimingMs: Int = 20, humanizeVelocity: Int = 10) {
        self.tempoBPM = tempoBPM
        self.humanizeTimingMs = humanizeTimingMs
        self.humanizeVelocity = humanizeVelocity
    }
    private func msPerQuarter() -> Double { return 60000.0 / Double(tempoBPM) }
    private func humanizeTicks(quarter: Double) -> Int {
        // add small timing jitter in ticks
        let baseTicks = Int(round(quarter * Double(ticksPerQuarter)))
        let jitterMs = Int.random(in: -humanizeTimingMs...humanizeTimingMs)
        let jitterQuarters = Double(jitterMs) / msPerQuarter()
        let jitterTicks = Int(round(jitterQuarters * Double(ticksPerQuarter)))
        return baseTicks + jitterTicks
    }
    func writeNoteEvents(melNotes: [MelodyNote], channel: UInt8 = 0, baseVelocity: UInt8 = 90, humanize: Bool = true) -> [UInt8] {
        struct Ev { let tick: Int; let isOn: Bool; let note: Int; let velocity: UInt8; let channel: UInt8 }
        var evs: [Ev] = []
        for n in melNotes {
            let startTick: Int = humanize ? humanizeTicks(quarter: n.startQuarter) : Int(round(n.startQuarter * Double(ticksPerQuarter)))
            let durTick = Int(round(n.durationQuarter * Double(ticksPerQuarter)))
            let vel: UInt8
            if humanize {
                let dv = Int.random(in: -humanizeVelocity...humanizeVelocity)
                vel = UInt8(clamp(Int(baseVelocity) + dv, 10, 127))
            } else { vel = baseVelocity }
            evs.append(Ev(tick: startTick, isOn: true, note: n.midi, velocity: vel, channel: channel))
            evs.append(Ev(tick: startTick + durTick, isOn: false, note: n.midi, velocity: 0, channel: channel))
        }
        evs.sort {
            if $0.tick != $1.tick { return $0.tick < $1.tick }
            if $0.isOn != $1.isOn { return $0.isOn && !$1.isOn }
            return $0.note < $1.note
        }
        var out: [UInt8] = []
        var lastTick = 0
        for e in evs {
            let delta = e.tick - lastTick
            out += vlq(delta)
            if e.isOn {
                out += [0x90 | e.channel, UInt8(e.note & 0x7F), e.velocity]
            } else {
                out += [0x80 | e.channel, UInt8(e.note & 0x7F), e.velocity]
            }
            lastTick = e.tick
        }
        return out
    }
    func writeDrumEvents(drums: [DrumHit], baseVelocity: UInt8 = 100, humanize: Bool = true) -> [UInt8] {
        struct Ev { let tick: Int; let isOn: Bool; let note: Int; let velocity: UInt8 }
        var evs: [Ev] = []
        for h in drums {
            let startTick: Int = humanize ? humanizeTicks(quarter: h.startQuarter) : Int(round(h.startQuarter * Double(ticksPerQuarter)))
            let durTick = Int(round(h.durationQuarter * Double(ticksPerQuarter)))
            let dv = humanize ? Int.random(in: -humanizeVelocity...humanizeVelocity) : 0
            let vel = UInt8(clamp(Int(baseVelocity) + dv, 1, 127))
            evs.append(Ev(tick: startTick, isOn: true, note: h.midi, velocity: vel))
            evs.append(Ev(tick: startTick + durTick, isOn: false, note: h.midi, velocity: 0))
        }
        evs.sort { if $0.tick != $1.tick { return $0.tick < $1.tick }; if $0.isOn != $1.isOn { return $0.isOn && !$1.isOn }; return $0.note < $1.note }
        var out: [UInt8] = []
        var lastTick = 0
        for e in evs {
            let delta = e.tick - lastTick
            out += vlq(delta)
            if e.isOn {
                out += [0x99, UInt8(e.note & 0x7F), e.velocity] // 
            } else {
                out += [0x89, UInt8(e.note & 0x7F), e.velocity]
            }
            lastTick = e.tick
        }
        return out
    }
    func buildFile(trackChunks: [[UInt8]]) -> Data {
        var data = Data()
        data.append(contentsOf: [0x4D,0x54,0x68,0x64]) 
        data.append(contentsOf: u32(6))
        data.append(contentsOf: u16(1))
        data.append(contentsOf: u16(UInt16(trackChunks.count)))
        data.append(contentsOf: u16(ticksPerQuarter))
        for chunk in trackChunks {
            data.append(contentsOf: [0x4D,0x54,0x72,0x6B]) 
            data.append(contentsOf: u32(UInt32(chunk.count)))
            data.append(contentsOf: chunk)
        }
        return data
    }
    func buildDefaultTracks(melody: [MelodyNote], bass: [MelodyNote], chords: [MelodyNote], drums: [DrumHit]) -> Data {
        var t0: [UInt8] = []
        t0 += [0x00, 0xFF, 0x51, 0x03]
        let mpq = 60000000 / tempoBPM
        let mpqBytes = u32(UInt32(mpq))
        t0 += [mpqBytes[1], mpqBytes[2], mpqBytes[3]] 
        t0 += [0x00, 0xFF, 0x58, 0x04, 4, 2, 24, 8]
        t0 += [0x00, 0xFF, 0x2F, 0x00]

        var t1: [UInt8] = []
        t1 += writeNoteEvents(melNotes: melody, channel: 0, baseVelocity: 90, humanize: true)
        t1 += [0x00, 0xFF, 0x2F, 0x00]

        var t2: [UInt8] = []
        t2 += [0x00, 0xC1, 32] 
        t2 += writeNoteEvents(melNotes: bass, channel: 1, baseVelocity: 96, humanize: true)
        t2 += [0x00, 0xFF, 0x2F, 0x00]

        var t3: [UInt8] = []
        t3 += [0x00, 0xC2, 0]
        t3 += writeNoteEvents(melNotes: chords, channel: 2, baseVelocity: 80, humanize: true)
        t3 += [0x00, 0xFF, 0x2F, 0x00]

        var t4: [UInt8] = []
        t4 += writeDrumEvents(drums: drums, baseVelocity: 100, humanize: true)
        t4 += [0x00, 0xFF, 0x2F, 0x00]

        return buildFile(trackChunks: [t0, t1, t2, t3, t4])
    }
}


let MAX_MIDI = 84
func simplePianoRoll(notes: [MelodyNote], minMidi: Int = 60, maxMidi: Int = MAX_MIDI) {
    let rows = (maxMidi - minMidi + 1)
    let totalQuarters = Int((notes.map{ $0.startQuarter + $0.durationQuarter }.max() ?? 0.0).rounded(.up))
    let cols = max(1, totalQuarters * 2) 
    var grid = Array(repeating: Array(repeating: " ", count: cols), count: rows)

    for n in notes {
        let pitchClamped = clamp(n.midi, minMidi, maxMidi)
        let row = maxMidi - pitchClamped
        let start = Int(round(n.startQuarter * 2.0))
        let length = max(1, Int(round(n.durationQuarter * 2.0)))
        for c in start..<(start+length) {
            if c >= 0 && c < cols && row >= 0 && row < rows {
                grid[row][c] = "█"
            }
        }
    }

    print("\nASCII Piano Roll (top = \(maxMidi))")
    for r in 0..<rows {
        let midi = maxMidi - r
        let name = Note(midi: midi).name.padding(toLength: 4, withPad: " ", startingAt: 0)
        let line = grid[r].joined()
        print("\(name) |\(line)|")
    }
}

struct Config {
    var style: String = "classical"
    var keyRoot: Int = 60
    var scale: ScaleType = .major
    var tempo: Int = 100
    var bars: Int = 8
    var useMarkov: Bool = false
}
func prompt(_ text: String, default def: String) -> String {
    print("\(text) [default: \(def)]: ", terminator: "")
    if let line = readLine(), !line.isEmpty { return line }
    return def
}

func main() {
    print("=== Swift Music Generator ===")
    var cfg = Config()
    let styleInput = prompt("Choose style (classical/jazz/minimal/ambient/edm)", default: cfg.style)
    cfg.style = styleInput.lowercased()
    let keyInput = prompt("Key root (C4=60)", default: "\(cfg.keyRoot)")
    cfg.keyRoot = Int(keyInput) ?? cfg.keyRoot
    let scaleInput = prompt("Scale (major/minorNatural/majorPentatonic/minorPentatonic)", default: cfg.scale.rawValue)
    cfg.scale = ScaleType(rawValue: scaleInput) ?? cfg.scale
    let tempoInput = prompt("Tempo (BPM)", default: "\(cfg.tempo)")
    cfg.tempo = Int(tempoInput) ?? cfg.tempo
    let barsInput = prompt("Bars (number of bars)", default: "\(cfg.bars)")
    cfg.bars = Int(barsInput) ?? cfg.bars
    let markovInput = prompt("Use Markov melody generator? (yes/no)", default: "no")
    cfg.useMarkov = (markovInput.lowercased() == "yes" || markovInput.lowercased() == "y")

    let key = Key(rootMidi: cfg.keyRoot, scale: cfg.scale)
    let harmonyEngine = HarmonyEngine(key: key)
    let preset: ProgressionPreset
    switch cfg.style {
    case "classical": preset = .classic
    case "jazz": preset = .jazzII_V_I
    case "minimal": preset = .random
    case "ambient": preset = .random
    case "edm": preset = .pop
    default: preset = .pop
    }
    let harmony = harmonyEngine.progression(preset: preset, bars: cfg.bars)
    print("\nKey: \(key.name), Tempo: \(cfg.tempo), Style: \(cfg.style), Bars: \(cfg.bars)")
    print("Progression:")
    for (i,ch) in harmony.enumerated() { print("Bar \(i+1): \(ch.name())") }

    let melodyNotes: [MelodyNote]
    if cfg.useMarkov {
        melodyNotes = MarkovMelodyGenerator(key: key, harmony: harmony, bars: cfg.bars).generateMelody()
    } else {
        melodyNotes = MelodyGenerator(key: key, harmony: harmony, bars: cfg.bars).generateMelody(style: cfg.style, complexity: cfg.style == "jazz" ? 0.9 : 0.6)
    }
    let bass = BassGenerator(key: key).generateBass(harmony: harmony)
    let arp = ChordArpGenerator().generateArpeggio(harmony: harmony)
    var chordTrack: [MelodyNote] = []
    for (i,ch) in harmony.enumerated() {
        let start = Double(i * 4)
        for n in ch.notes(octaveShift: 1) {
            chordTrack.append(MelodyNote(midi: n.midi + 12, startQuarter: start, durationQuarter: 4.0))
        }
    }

    let drums = DrumGenerator().generatePattern(bars: cfg.bars)

    print("\n--- Melody Notes ---")
    let sortedMel = melodyNotes.sorted { $0.startQuarter < $1.startQuarter }
    for n in sortedMel {
        print(String(format: "%5.2f - %5.2f : %@ (%d)", n.startQuarter, n.startQuarter + n.durationQuarter, Note(midi: n.midi).name, n.midi))
    }

    print("\nGenerating ASCII piano roll (melody + chords + arp)...")
    var combined: [MelodyNote] = melodyNotes + chordTrack + arp
    combined = combined.map { MelodyNote(midi: clamp($0.midi, 48, 84), startQuarter: $0.startQuarter, durationQuarter: $0.durationQuarter) }
    simplePianoRoll(notes: combined, minMidi: 60, maxMidi: 84)

    let writer = MIDIWriter(tempoBPM: cfg.tempo, humanizeTimingMs: 12, humanizeVelocity: 8)
    let midiData = writer.buildDefaultTracks(melody: melodyNotes, bass: bass, chords: chordTrack + arp, drums: drums)
    let outURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("composition.mid")
    do {
        try midiData.write(to: outURL)
        print("\nWrote MIDI file to: \(outURL.path)")
    } catch {
        print("\nFailed to write file (REPL may forbid). Printing base64 MIDI for download:")
        print(Data(midiData).base64EncodedString())
    }

    print("\n--- Textual dump (first 200 events) ---")
    var eventCount = 0
    let maxDump = 200
    func dumpNotes(_ notes: [MelodyNote], label: String) {
    for n in notes {
        if eventCount >= maxDump { return }
        let startStr = String(format: "%5.2f", n.startQuarter)
        let endStr = String(format: "%5.2f", n.startQuarter + n.durationQuarter)
        let noteName = Note(midi: n.midi).name
        let s = "\(label) | \(startStr) -> \(endStr) : \(noteName) (\(n.midi))"
        print(s)
        eventCount += 1
    }
}

    dumpNotes(melodyNotes, label: "Mel")
    dumpNotes(bass, label: "Bass")
    dumpNotes(chordTrack + arp, label: "Chord")
    if eventCount < maxDump {
        for d in drums {
            if eventCount >= maxDump { break }
            print(String(format: "Drum | %5.2f : MIDI %d", d.startQuarter, d.midi))
            eventCount += 1
        }
    }

    print("\nDone. composition.mid created (if permitted). Open in DAW or decode base64.")
}

main()
