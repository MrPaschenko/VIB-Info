import Foundation

struct Departure: Codable {
    let id: String
    let day: String
    let time: String
    let status: String
    let destination: String
    let lineDescription: String
    let carrier: String
    let gate: String
    let delay: String
    let delayText: String
    let line: String
    let via: String
    let checkIn: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case day = "tagbez"
        case time = "abfahrtGepl"
        case status = "abfahrt"
        case destination = "ziel"
        case lineDescription = "linienbeschreibung"
        case carrier = "carrier"
        case gate = "gate"
        case delay = "verspaetung"
        case delayText = "delay_text"
        case line = "linie"
        case via = "via"
        case checkIn = "CheckIn"
    }
}
