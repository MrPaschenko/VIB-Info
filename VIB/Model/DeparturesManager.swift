import Foundation

struct DeparturesManager {
    let url = "https://vib-wien.at/fileadmin/apiv4/fetchVIBDepartures.php"
    
    var departures: [Departure] {
        get async throws {
            let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
            return try JSONDecoder().decode(DeparturesResponseData.self, from: data).result
        }
    }
}
