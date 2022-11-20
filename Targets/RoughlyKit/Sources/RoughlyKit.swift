import Foundation
import NaturalLanguage

let formatterDouble: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 2
    return formatter
}()

let formatterInt: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    return formatter
}()

let formatterPercentage: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 3
    return formatter
}()

public protocol RoughlyUnit: Hashable, Identifiable, CaseIterable {
    associatedtype MyUnit: Dimension
    var unit: MyUnit {get}
    
    func times(_ measurement: Measurement<MyUnit>) -> Measurement<MyUnit>
}

public extension RoughlyUnit {
    var id: Self { self }
    func times(_ measurement: Measurement<MyUnit>) -> Measurement<MyUnit> {
        measurement.converted(to: unit)
    }
}

public enum Category: Hashable, Identifiable, CaseIterable {
    public static var allCases: [Category] =
    Category.Area.allCases.map(Category.area) + Category.Weight.allCases.map(Category.weight)
    
    public var id: Self { self }
    
    public enum Area: RoughlyUnit {
        case trafalgarSquare
        case tennisCourt
        case footballArea
        case basketballCourt
        case kingSizeBed
        case dinnerPlate
        case iPhoneScreenDisplay
        
        public var measurement: Measurement<UnitArea> {
            switch self {
            case .trafalgarSquare: return Measurement(value: 12000, unit: .baseUnit())
            case .footballArea: return Measurement(value: 5351.215, unit: .baseUnit())
            case .basketballCourt: return Measurement(value: 495.63771840, unit: .baseUnit())
            case .tennisCourt: return Measurement(value: 260.871740, unit: .baseUnit())
            case .kingSizeBed: return Measurement(value: 4.03, unit: .baseUnit())
            case .dinnerPlate: return Measurement(value: 0.0452, unit: .baseUnit())
            case .iPhoneScreenDisplay: return Measurement(value: 0.0083, unit: .baseUnit())
            }
        }
        
        public var unit: UnitArea {
            let converter = UnitConverterLinear(coefficient: measurement.value)
            switch self {
            case .trafalgarSquare: return MyUnit(symbol: "Trafalgar squares", converter: converter)
            case .footballArea: return MyUnit(symbol: "football grounds", converter: converter)
            case .basketballCourt: return MyUnit(symbol: "basketball courts", converter: converter)
            case .tennisCourt: return MyUnit(symbol: "tennis courts", converter: converter)
            case .kingSizeBed: return MyUnit(symbol: "king size beds", converter: converter)
            case .dinnerPlate: return MyUnit(symbol: "dinner plates", converter: converter)
            case .iPhoneScreenDisplay: return MyUnit(symbol: "iPhone screen displays", converter: converter)
            }
        }
    }
    
    public enum Weight: RoughlyUnit {
        case cat
        case glassOfWater
        case tablespoon
        case humanBrain
        case aaaBattery
        case paper
        case panda
        
        public var measurement: Measurement<UnitMass> {
            switch self {
            case .panda: return Measurement(value: 150, unit: .baseUnit())
            case .cat: return Measurement(value: 5, unit: .baseUnit())
            case .humanBrain: return Measurement(value: 1.350, unit: .baseUnit())
            case .glassOfWater: return Measurement(value: 0.25, unit: .baseUnit())
            case .aaaBattery: return Measurement(value: 0.024, unit: .baseUnit())
            case .paper: return Measurement(value: 0.005, unit: .baseUnit())
            case .tablespoon: return Measurement(value: 0.014175, unit: .baseUnit())
            }
        }
        
        public var unit: UnitMass {
            let converter = UnitConverterLinear(coefficient: measurement.value)
            switch self {
            case .panda: return MyUnit(symbol: "pandas", converter: converter)
            case .cat: return MyUnit(symbol: "cats", converter: converter)
            case .tablespoon: return MyUnit(symbol: "tablespoons", converter: converter)
            case .humanBrain: return MyUnit(symbol: "human brains", converter: converter)
            case .glassOfWater: return MyUnit(symbol: "glasses of water", converter: converter)
            case .aaaBattery: return MyUnit(symbol: "AAA batteries", converter: converter)
            case .paper: return MyUnit(symbol: "papers", converter: converter)
            }
        }
    }
    
    case area(Area)
    case weight(Weight)
    
    var title: String {
        switch self {
        case .area: return "Area"
        case .weight: return "Weight"
        }
    }
    
    public var unit: Unit {
        switch self {
        case let .area(area): return area.unit
        case let .weight(weight): return weight.unit
        }
    }
    
    public func times(unit: Unit, val: Double) -> Double {
        switch self {
        case let .weight(weight):
            if let selectedUnit = unit as? UnitMass {
                let measure = Measurement(value: val, unit: selectedUnit)
                return weight.times(measure).value
            }
            
        case let .area(area):
            if let selectedUnit = unit as? UnitArea {
                let measure = Measurement(value: val, unit: selectedUnit)
                return area.times(measure).value
            }
        }
        return 0
    }
}

public struct Measure {
    public init(measurement: Measurement<Unit>) {
        self.measurement = measurement
    }
    
    public let measurement: Measurement<Unit>
    
    private var pluralForm: String {
        measurement.unit.symbol
    }
    
    public var title: String {
        if roundedIntValue == "1" {
            return singleForm
        } else {
            return pluralForm
        }
    }
    
    private var singleForm: String {
        let text = measurement.unit.symbol
        var words = text.split(separator: " ").map(String.init)
        guard let lastWord = words.popLast() else  { return text }
        
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = lastWord
        tagger.setLanguage(.english, range: lastWord.startIndex..<lastWord.endIndex)
        let (tag, range) = tagger.tag(at: lastWord.startIndex, unit: .word, scheme: .lemma)
        let modifiedLastWord = tag?.rawValue ?? String(lastWord[range])
        words.append(modifiedLastWord)
        let output = words.joined(separator: " ")
        
        return output
    }
    
    public var roundedIntValue: String {
        formatterInt.string(from: NSNumber(value: measurement.value)) ?? ""
    }
    
    public var roundedDoubleValue: String? {
        let val = NSNumber(value: measurement.value)
        if val.decimalValue.isZero { return nil } else { return formatterDouble.string(from: val) ?? "" }
      
    }
    
    public var percentage: String? {
        let intDouble = Double(roundedIntValue)
        guard let roundedDoubleValue, let doubleDouble = Double(roundedDoubleValue) else { return nil }
        guard let intDouble else {return nil}
        let difference = (intDouble - doubleDouble) / 100
        guard !difference.isZero else { return nil }
        return formatterPercentage.string(from: NSNumber(value: difference))
    }
}
