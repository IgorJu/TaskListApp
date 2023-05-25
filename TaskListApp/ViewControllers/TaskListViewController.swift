//
//  TaskListViewController.swift
//  TaskListApp
//
//  Created by Alexey Efimov on 17.05.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let storageManager = StorageManager.shared
    private let cellID = "cell"
    
    private var taskList: [Task] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    //MARK: - Deleting rows
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        storageManager.delete(task: task)
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    //MARK: - Editing rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
        showAlert(task: task) {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK: - Adding rows
    private func save(_ taskName: String) {
        storageManager.save(taskName: taskName) { [weak self] task in
            let indexPath = IndexPath(row: (self?.taskList.count ?? 0), section: 0)
            self?.taskList.append(task)
            self?.tableView.insertRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: - @objc method
    @objc private func addNewTask() {
        showAlert()
    }
    
    private func fetchData() {
        storageManager.fetchData { [unowned self] result in
            switch result {
            case .success(let taskList):
                self.taskList = taskList
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

//MARK: - Alert

extension TaskListViewController {
    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {
        let alertFactory = AlertControllerFactory(
            userAction: task != nil ? .editTask : .newTask,
            taskTitle: task?.title
        )
        let alert = alertFactory.createAlert { [weak self] taskName in
            if let task, let completion {
                self?.storageManager.edit(task: task, to: taskName)
                completion()
                return
            }
            self?.save(taskName)
        }
        
        present(alert, animated: true)
    }
}


// MARK: - SetupUI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}

