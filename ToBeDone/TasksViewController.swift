//
//  TasksViewController.swift
//  ToBeDone
//
//  Created by Udrea Alexandru-Iulian-Alberto on 19.11.2022.
//

import UIKit
import FirebaseAuth

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CompletableTaskDelegate {
    func pressComplete( _ button: UIButton?) {
        if state == "unfinished" {
            var completedTask = uncompletedTasks?[button?.tag ?? 0]
            completedTask?.finished = true
            if let task = completedTask{
                updateTask(updatedTask: task) { data, response, error in
                    if let error = error {
                        let alert = UIAlertController(title: "Error at completing task. Try again please.", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        DispatchQueue.main.async {
                            self.present(alert, animated: true, completion: nil)
                        }
                        return
                    }
                }
                DispatchQueue.main.async {
                    self.refresh(self)
                }
            }
        }
    }
    
    func changeTask(_ button: UIButton) {
        print("delegat")
        performSegue(withIdentifier: "edit", sender: self)
    }
    
    
    @IBOutlet weak var picker: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var logout: UIButton!
    private var requestedTasks : [TaskModel]? = []
    private var uncompletedTasks : [TaskModel]? = []
    private var completedTasks : [TaskModel]? = []
    private var uid = ""
    let refreshControl = UIRefreshControl()
    private var state = "finished"
     
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.clipsToBounds = true
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        listButton.layer.cornerRadius = 0.5 * listButton.bounds.size.width
        listButton.clipsToBounds = true
        listButton.layer.borderWidth = 1
        listButton.layer.borderColor = UIColor.link.cgColor
        plusButton.layer.cornerRadius = 0.5 * plusButton.bounds.size.width
        plusButton.clipsToBounds = true
        plusButton.layer.borderWidth = 1
        plusButton.layer.borderColor = UIColor.link.cgColor
        logout.layer.cornerRadius = 0.5 * logout.bounds.size.width
        logout.clipsToBounds = true
        logout.layer.borderWidth = 1
        logout.layer.borderColor = UIColor.link.cgColor
        logout.tintColor = UIColor.link
        self.navigationItem.hidesBackButton = true
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        picker.addTarget(self, action: #selector(self.selectTypeOfTask(sender:)), for:.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func updateViewController() {
        self.tableView.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        refreshControl.beginRefreshing()
        switch state {
        case "total":
            getTasks(id: uid) { result in
                switch result {
                case .success(let tasks):
                    self.requestedTasks = tasks
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        case "finished":
            getFinishedTasks(id: uid) { result in
                switch result {
                case .success(let tasks):
                    self.completedTasks = tasks
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        case "unfinished":
            getUnfinishedTasks(id: uid) { result in
                switch result {
                case .success(let tasks):
                    self.uncompletedTasks = tasks
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        default: break
            
        }
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = Auth.auth().currentUser {
            let id = user.uid
            uid = id
            print(id)
        } else {
            //
        }
        switch state {
        case "total":
            getTasks(id: uid) { result in
                switch result {
                case .success(let tasks):
                    self.requestedTasks = tasks
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        case "finished":
            getFinishedTasks(id: uid) { result in
                switch result {
                case .success(let tasks):
                    self.completedTasks = tasks
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        case "unfinished":
            getUnfinishedTasks(id: uid) { result in
                switch result {
                case .success(let tasks):
                    self.uncompletedTasks = tasks
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        default: break
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch state {
        case "total":
            return requestedTasks?.count ?? 0
        case "unfinished":
            return uncompletedTasks?.count ?? 0
        case "finished":
            return completedTasks?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        cell.showsReorderControl = true
        switch state {
        case "total":
            if let task = requestedTasks?[indexPath.section]{
                var color : UIColor = .link
                switch task.priority {
                case 1:
                    color = .link
                case 2:
                    color = .green
                case 3:
                    color = .red
                case 4:
                    color = .blue
                case 5:
                    color = .orange
                default:
                    color = .link
                }
                cell.configureTaskCell(task, tag: indexPath.section, color: color, finished: task.finished!, delegate: self)
            }
        case "finished":
            if let task = completedTasks?[indexPath.section]{
                var color : UIColor = .link
                switch task.priority {
                case 1:
                    color = .link
                case 2:
                    color = .green
                case 3:
                    color = .red
                case 4:
                    color = .blue
                case 5:
                    color = .orange
                default:
                    color = .link
                }
                cell.configureTaskCell(task, tag: indexPath.section, color: color, finished: true,delegate: self)
            }
        case "unfinished":
            if let task = uncompletedTasks?[indexPath.section]{
                var color : UIColor = .link
                switch task.priority {
                case 1:
                    color = .link
                case 2:
                    color = .green
                case 3:
                    color = .red
                case 4:
                    color = .blue
                case 5:
                    color = .orange
                default:
                    color = .link
                }
                cell.configureTaskCell(task, tag: indexPath.section, color: color, finished: false, delegate: self)
            }
        default :
            break
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Edit", bundle:nil)
        let editViewController = storyBoard.instantiateViewController(withIdentifier: "Edit") as! EditViewController
        switch state {
        case "unfinished":
            if let task = uncompletedTasks?[indexPath.section]{
                editViewController.task = task
                navigationController?.present(editViewController, animated: true)
            }
        default:
            break
        }
        
    }
    
    @IBAction func logout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let err {
            print(err)
        }
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Settings", bundle:nil)
        let settingsViewController = storyBoard.instantiateViewController(withIdentifier: "settings") as! SettingsViewController
        
        if let total = self.requestedTasks?.count{
            if let uncompleted = self.uncompletedTasks?.count{
                let numbers = NumberOfTasks(totalTasks: total , uncompleted: uncompleted)
                settingsViewController.numbers = numbers
                navigationController?.present(settingsViewController, animated: true)
            }
        }
    }
    
    
    @objc func selectTypeOfTask(sender: UISegmentedControl) {
        switch picker.selectedSegmentIndex
        {
        case 0:
            state = "total"
            refresh(self)
        case 1:
            state = "finished"
            refresh(self)
        case 2:
            state = "unfinished"
            refresh(self)
        default:
            break;
        }
    }
}


struct NumberOfTasks {
    var totalTasks : Int? = 0
    var uncompleted : Int? = 0
}
