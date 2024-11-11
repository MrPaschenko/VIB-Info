import Foundation

struct Arrival: Codable {
    let id: String
    let day: String
    let time: String
    let status: String
    let departure: String
    let lineDescription: String
    let carrier: String
    let gate: String
    let delay: String
    let delayText: String
    let line: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case day = "tagbez"
        case time = "ankunftGepl"
        case status = "ankunft"
        case departure = "von"
        case lineDescription = "linienbeschreibung"
        case carrier = "carrier"
        case gate = "gate"
        case delay = "verspaetung"
        case delayText = "delay_text"
        case line = "linie"
    }
}

struct ArrivalsResponseData: Codable {
    let result: [Arrival]
}
