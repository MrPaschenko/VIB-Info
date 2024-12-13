import UIKit

class DeparturesTableViewController: UITableViewController {
    var departuresManager = DeparturesManager()
    
    var departures: [Departure] = []
    var filteredDepartures: [Departure] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = String(localized: "departures")
        searchBar.placeholder = String(localized: "search")
        
        if let tabBarController = self.tabBarController, let viewControllers = tabBarController.viewControllers {
            let rightNavController = viewControllers[1]
            rightNavController.title = String(localized: "arrivals")
        }
        
        Task {
            do {
                departures = try await departuresManager.departures
                filteredDepartures = departures
                
                tableView.reloadData()
            } catch {
                print("Error getting departures: \(error)")
            }
        }
    }
        
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDepartures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departureIdentifier", for: indexPath)
        
        var configuration = cell.defaultContentConfiguration()
        let departure = filteredDepartures[indexPath.row]
        
        let lineTrimmed = departure.line.trimmingCharacters(in: .whitespaces)
        let destinationTrimmed = departure.destination.trimmingCharacters(in: .whitespaces)
        
        var configurationText = "\(lineTrimmed): \(destinationTrimmed)"
        
        if destinationTrimmed == "" {
            configurationText = lineTrimmed
        }
        
        if departure.via != "" && departure.via != "-" && departure.via != "." && departure.via != "," {
            var viaTrimmed = departure.via.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "  ", with: " ")
            
            if viaTrimmed.last == "-" {
                viaTrimmed.removeLast()
                viaTrimmed = viaTrimmed.trimmingCharacters(in: .whitespaces)
            }
            
            if viaTrimmed.last == "," {
                viaTrimmed.removeLast()
            }
            
            configurationText.append(" (\(String(localized: "via")) \(viaTrimmed))")
        }
        configuration.text = configurationText
        
        let secondaryText = NSMutableAttributedString()
        
        let greenAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGreen]
        let yellowAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemYellow]
        
        var timeStatusText = ""
        if departure.status == "on time" {
            timeStatusText = "\(departure.time) (\(String(localized: "onTime")))"
        } else {
            timeStatusText = "\(departure.time) (\(departure.status)"
        }
        
        let attributedGreenTimeStatus = NSAttributedString(string: timeStatusText, attributes: greenAttributes)
        let attributedYellowTimeStatus = NSAttributedString(string: timeStatusText, attributes: yellowAttributes)
        
        if departure.status == "on time" {
            secondaryText.append(attributedGreenTimeStatus)
        } else {
            secondaryText.append(attributedYellowTimeStatus)
        }
        
        if departure.status != "on time" {
            let delayText = " • \(String(localized: "delay")): \(departure.delay) (\(departure.delayText))"
            let attributedDelay = NSAttributedString(string: delayText)
            secondaryText.append(attributedDelay)
        }
        
        let gateText = " • \(String(localized: "gate")) \(departure.gate)"
        let attributedGate = NSAttributedString(string: gateText)
        secondaryText.append(attributedGate)
        
        configuration.secondaryAttributedText = secondaryText
        
        cell.contentConfiguration = configuration
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let departure = filteredDepartures[indexPath.row]
        
        var detailsMessage = ""
        
        var carrierMessage = "\(String(localized: "carrier")): \(departure.carrier.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "  ", with: " "))"
        if departure.lineDescription != departure.carrier {
            carrierMessage.append(" (\(departure.lineDescription))")
        }
        detailsMessage.append(carrierMessage)
        
        
        
        detailsMessage.append("\n\n\(String(localized: "route")): \(departure.line)")
        
        var destinationMessage = "\n\n\(String(localized: "destinationCity")): \(departure.destination)"
        
        if departure.via != "" && departure.via != "-" && departure.via != "." && departure.via != "," {
            var viaTrimmed = departure.via.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "  ", with: " ")
            
            if viaTrimmed.last == "-" {
                viaTrimmed.removeLast()
                viaTrimmed = viaTrimmed.trimmingCharacters(in: .whitespaces)
            }
            
            if viaTrimmed.last == "," {
                viaTrimmed.removeLast()
            }
            
            destinationMessage.append(" (\(String(localized: "via")) \(viaTrimmed))")
        }
        detailsMessage.append(destinationMessage)
        
        var timeMessage = "\n\n\(String(localized: "time")): \(departure.time)"
        if departure.status == "on time" {
            timeMessage.append(" (\(String(localized: "onTime")))")
        }
        detailsMessage.append(timeMessage)
        
        if departure.status != "on time" {
            let delayText = "\n\(String(localized: "delay")): \(departure.delay) (\(departure.delayText))"
            detailsMessage.append(delayText)
        }
        
        detailsMessage.append("\n\n\(String(localized: "gate")): \(departure.gate)")
        
        let alertController = UIAlertController(title: String(localized: "departureDetails"), message: detailsMessage, preferredStyle: .alert)
        alertController.view.tintColor = .accent
        let okAction = UIAlertAction(title: String(localized: "ok"), style: .cancel)
        let openWebsiteAction = UIAlertAction(title: String(localized: "moreInformation"), style: .default) { _ in
            if let url = URL(string: "https://vib-wien.at/abfahrten") {
                UIApplication.shared.open(url)
            }
        }
        
        alertController.addAction(okAction)
        alertController.addAction(openWebsiteAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        Task {
            do {
                departures = try await departuresManager.departures
                filteredDepartures = departures
                                
                tableView.reloadData()
            } catch {
                print("Error getting departures: \(error)")
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            sender.endRefreshing()
        }
    }
}

//MARK: - Search

extension DeparturesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredDepartures = searchText == "" ? departures : []
        
        for departure in departures {
            if departure.line.uppercased().contains(searchText.uppercased()) || departure.destination.uppercased().contains(searchText.uppercased()) || departure.via.uppercased().contains(searchText.uppercased()) {
                filteredDepartures.append(departure)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}
