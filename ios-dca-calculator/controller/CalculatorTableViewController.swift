//
//  CalculatorTableViewController.swift
//  ios-dca-calculator
//
//  Created by ozan honamlioglu on 30.05.2021.
//

import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyDollarCostAveragingTextField: UITextField!
    @IBOutlet weak var initialDateOfInvestmentTextField: UITextField!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabel: [UILabel]!
    @IBOutlet weak var investmentAmountCurrencyLabel: UILabel!
    @IBOutlet weak var dateSlider: UISlider!
    @IBOutlet weak var currentValueLable: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var annualReturnLabel: UILabel!
    
    var asset: Asset?
    private var initialDateOfInvestmentIndex: IndexPath? {
        willSet {
            guard newValue != nil else { return }
            dateSlider.value = newValue!.item.floatValue
        }
    }
    
    @Published private var initialInvestmentAmount: Int?
    @Published private var monthlyDollarCostAveragingAmount: Int?
    private var bag = Set<AnyCancellable>()
    private let dcaService = DCAService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTextViews()
        setupDateSlider()
        observeForm()
    }
    
    private func setupViews() {
        symbolLabel.text = asset?.searchResult.symbol
        nameLabel.text = asset?.searchResult.name
        investmentAmountCurrencyLabel.text = asset?.searchResult.currency
        
        currencyLabel.forEach { label in
            label.text = asset?.searchResult.currency.addBracket()
        }
    }
    
    private func setupTextViews() {
        initialInvestmentAmountTextField.addDoneButton()
        monthlyDollarCostAveragingTextField.addDoneButton()
        initialDateOfInvestmentTextField.delegate = self
    }
    
    private func observeForm() {
        NotificationCenter
            .default
            .publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .sink { [weak self] text in
                self?.initialInvestmentAmount = Int(text) ?? 0
            }
            .store(in: &bag)
        
        NotificationCenter
            .default
            .publisher(for: UITextField.textDidChangeNotification, object: monthlyDollarCostAveragingTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .sink { [weak self] text in
                self?.monthlyDollarCostAveragingAmount = Int(text) ?? 0
            }
            .store(in: &bag)
        
        Publishers
            .CombineLatest($initialInvestmentAmount, $monthlyDollarCostAveragingAmount)
            .sink { [weak self] invAmount, avgAmount in
                
                guard let invAmount = invAmount, let avgAmount = avgAmount, let initialDateOfInvestmentIndex = self?.initialDateOfInvestmentIndex else { return }
                let result = self?.dcaService.calculate(initialInvestmentAmount: invAmount.doubleValue, monthlyDollarCostAveragingAmount: avgAmount.doubleValue, initialDateOfInvestmentIndex: initialDateOfInvestmentIndex.item)
                
                self?.currentValueLable.text = result?.currentValue.stringValue
                self?.investmentAmountLabel.text = result?.investmentAmount.stringValue
                self?.gainLabel.text = result?.gain.stringValue
                self?.yieldLabel.text = result?.yield.stringValue
                self?.annualReturnLabel.text = result?.annualReturn.stringValue
            }
            .store(in: &bag)
    }
    
    private func setupDateSlider() {
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count {
            dateSlider.maximumValue = count.floatValue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dateSelectionTableViewController = segue.destination as? DateSelectionTableViewController, let timeSeriesMonthlyAdjusted = sender as? TimeSeriesMonthlyAdjusted {
            dateSelectionTableViewController.timeSeriesMonthlyAdjusted = timeSeriesMonthlyAdjusted
            dateSelectionTableViewController.didSelectDate = handleDateSelection
            dateSelectionTableViewController.selectedIndexPath = initialDateOfInvestmentIndex
        }
    }
    
    private func handleDateSelection(at indexPath: IndexPath) {
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        
        if let monthInfos = asset?.timeSeriesMonthlyAdjusted.getMonthInfos() {
            let index = indexPath.row
            initialDateOfInvestmentIndex = indexPath
            let monthInfo = monthInfos[index]
            let dateString = monthInfo.date.MMYYFormat
            initialDateOfInvestmentTextField.text = dateString
        }
    }
    
    @IBAction func dateSliderDidChange(_ sender: UISlider) {
        if(asset != nil && (Int(sender.value) < asset!.timeSeriesMonthlyAdjusted.getMonthInfos().count)) {
            if let dateString = asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[Int(sender.value)].date.MMYYFormat {
                initialDateOfInvestmentTextField.text = dateString
                let indexpath = IndexPath(row: Int(sender.value), section: 0)
                initialDateOfInvestmentIndex = indexpath
            }
        }
    }
}

extension CalculatorTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == initialDateOfInvestmentTextField {
            performSegue(withIdentifier: "showDateSelection", sender: asset?.timeSeriesMonthlyAdjusted)
            return false
        }
        
        return true
    }
    
}
