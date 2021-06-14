//
//  DateSelectionTableviewController.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 8.06.2021.
//

import UIKit

class DateSelectionTableViewController: UITableViewController {
    
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted?
    var selectedIndexPath: IndexPath?
    private var monthInfos: [MonthInfo] = []
    
    var didSelectDate: ((IndexPath) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupMonthInfos()
        
        if (selectedIndexPath != nil) {
            tableView.scrollToRow(at: selectedIndexPath!, at: .middle, animated: true)
        }
    }
    
    private func setupNavigation() {
        title = "Select date"
    }
    
    private func setupMonthInfos() {
        monthInfos = timeSeriesMonthlyAdjusted?.getMonthInfos() ?? []
    }
    
}

extension DateSelectionTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.item
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! DateSelectionTableViewCell
        let monthInfo = monthInfos[index]
        let isSelected = selectedIndexPath?.item == index
        
        cell.configure(with: monthInfo, index: indexPath.item, isSelected: isSelected)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectDate?(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

class DateSelectionTableViewCell: UITableViewCell {
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel!
    
    func configure(with monthInfo: MonthInfo, index: Int, isSelected: Bool) {
        monthLabel.text = monthInfo.date.MMYYFormat
        accessoryType = isSelected ? .checkmark : .none
        
        if index == 1 {
            monthsAgoLabel.text = "1 month ago"
        } else if index > 1 {
            monthsAgoLabel.text = "\(index) months ago"
        } else {
            monthsAgoLabel.text = "Just invested"
        }
    }
    
}
