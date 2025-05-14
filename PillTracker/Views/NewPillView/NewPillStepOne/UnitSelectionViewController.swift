//
//  UnitSelectionViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 09.04.2025.
//

import UIKit

class UnitSelectionViewController: UIViewController {
    
    var units = ["мл", "мг", "мкг", "г", "%", "мг/мл", "МЕ", "Капля", "Таблетка", "Капсула", "Пакетик", "Укол", "Пшик"]
    var selectedUnit: ((String) -> Void)?
    var dosage: Double = 0
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
}

// MARK: - UITableViewDataSource
extension UnitSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return units.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let unit = units[indexPath.row]
        
        let formattedUnit = getUnitTitle(for: dosage, unit: unit)
        
        cell.textLabel?.text = formattedUnit
        cell.textLabel?.textColor = .dGray
        cell.textLabel?.textAlignment = .center
        cell.separatorInset = UIEdgeInsets.zero 
        cell.layoutMargins = UIEdgeInsets.zero
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension UnitSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUnit = units[indexPath.row]
        self.selectedUnit?(selectedUnit)
        
        tableView.deselectRow(at: indexPath, animated: false)

        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension UnitSelectionViewController: UIViewControllerTransitioningDelegate {
    func presentAsBottomSheet(on parent: UIViewController) {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
        parent.present(self, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension UnitSelectionViewController {
    private func getUnitTitle(for dosage: Double, unit: String) -> String {
        return String.getUnitTitle(for: dosage, unit: unit)
    }
}
