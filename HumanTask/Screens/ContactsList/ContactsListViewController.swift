import Foundation
import SwiftUI
import UIKit
import ComposableArchitecture
import Then
import TinyConstraints
import API
// swiftlint:disable cyclomatic_complexity

class ContactsListViewController: UIViewController, UITableViewDelegate {
    private let store: Store<ContactsListFeature.State, ContactsListFeature.Action>
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    private lazy var blurView: BlurView = BlurView(contentView: tableView)
    private var dataSource: UITableViewDiffableDataSource<ContactsListSection, ContactsListItem>?
    var didSelectContact: ((Contact) -> Void)?
    
    init(store: Store<ContactsListFeature.State, ContactsListFeature.Action>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let tableView = UITableView(frame: .zero, style: .plain)
        let refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction(handler: { [weak self] _ in
            self?.store.send(.reloadContacts)
        }))
        tableView.refreshControl = refreshControl
        self.tableView = tableView

        // common
        view.backgroundColor = DesignSystem.Color.traitWhite
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = DesignSystem.Color.traitWhite
        appearance.shadowColor = nil
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // countdown
        let countdownView = CountdownView(store: store)
        let hostingController = UIHostingController(rootView: countdownView)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            hostingController.view.heightAnchor.constraint(equalToConstant: 90)
        ])
        if #available(iOS 16.0, *) {
            hostingController.sizingOptions = .intrinsicContentSize
        } else {
            hostingController.view.setNeedsUpdateConstraints()
        }

        // blur
        let blurView = BlurView(contentView: tableView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.blurRadius = 3
        blurView.opaqueEnabled = true
        self.blurView = blurView

        // tableview
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.do {
            $0.register(ContactsListCell.self, forCellReuseIdentifier: "cell")
            $0.rowHeight = 60
            $0.delegate = self
        }
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.tableHeaderView = createTableHeaderView(withTitle: "Submissions")
        tableView.separatorStyle = .none
        
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if let userCell = cell as? ContactsListCell {
                userCell.configure(contact: item.contact, data: item.rates)
            }
            return cell
        }
        observe { [weak self] in
            guard let self else {
                return
            }
            if store.submissionDate < store.timestamp {
                if !self.blurView.isDescendant(of: self.view) {
                    setBlurView(hostingController: hostingController)
                }
            }
        }
        observe { [weak self] in
            guard let self else {
                return
            }
            dataSource?.apply(store.snapshot, animatingDifferences: false)
        }
        observe { [weak self] in
            guard let self else {
                return
            }
            if store.isLoading {
                refreshControl.beginRefreshing()
            } else {
                refreshControl.endRefreshing()
            }
        }
        observe { [weak self] in
            guard let self else {
                return
            }
            if let error = store.error {
                let alertViewController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alertViewController.addAction(UIAlertAction(title: "OK", style: .default))
                present(alertViewController, animated: true)
            }
        }
        
        store.send(.waitContacts)
        store.send(.waitExchangeRates)
        
        store.send(.startExchangeRatesTimer)
    }
    
    private func createTableHeaderView(withTitle title: String) -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = DesignSystem.Color.traitWhite
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        if self.traitCollection.userInterfaceStyle == .dark {
            titleLabel.textColor = UIColor.white
        } else {
            titleLabel.textColor = UIColor.black
        }
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        let headerHeight: CGFloat = 50
        headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)
        return headerView
    }
    
    private func setBlurView(hostingController: UIViewController) {
        self.tableView.isUserInteractionEnabled = false
        self.view.addSubview(self.blurView)
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for indexPath in tableView.indexPathsForSelectedRows ?? [] {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSource?.itemIdentifier(for: indexPath) {
            didSelectContact?(item.contact)
        }
    }
}
