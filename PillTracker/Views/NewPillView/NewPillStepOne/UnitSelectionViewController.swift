//
//  UnitSelectionViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 09.04.2025.
//

import UIKit

final class UnitSelectionViewController: UIViewController {
    // MARK: - Public Properties
    var selectedUnit: ((String) -> Void)?
    var dosage: Double = 0
    
    // MARK: - Private Properties
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return tableView
    }()
    
    private let cellIdentifier = "UnitCell"
    private var units = ["мл", "мг", "мкг", "г", "%", "мг/мл", "МЕ", "Капля", "Таблетка", "Капсула", "Пакетик", "Укол", "Пшик"]
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
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
    
    private func configureCell(_ cell: UITableViewCell, for unit: String) {
        let formattedUnit = getUnitTitle(for: dosage, unit: unit)
        cell.textLabel?.text = formattedUnit
        cell.textLabel?.textColor = .dGray
        cell.textLabel?.textAlignment = .center
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }
    
    private func getUnitTitle(for dosage: Double, unit: String) -> String {
        return String.getUnitTitle(for: dosage, unit: unit)
    }
}

// MARK: - UITableViewDataSource
extension UnitSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return units.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let unit = units[indexPath.row]
        configureCell(cell, for: unit)
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
        modalPresentationStyle = .custom
        transitioningDelegate = self
        parent.present(self, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
