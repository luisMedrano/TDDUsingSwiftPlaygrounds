//: A UIKit based Playground for presenting user interface

import UIKit
import PlaygroundSupport
import XCTest

enum ActionSection: Int{
    case Todo
    case Done
}

class TableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    lazy var tableView:UITableView = {
        return UITableView()
    }()
    
    lazy var todoManager: TaskManager = {
        return TaskManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = CGRect(x: 0, y: 0, width: 375.0, height: 668.0)
        self.tableView = UITableView(frame:frame)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view?.addSubview(self.tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.generateTaskData()
    }
    
    func generateTaskData() {
        self.todoManager.addItemToTodoList(task: Task(title: "Xcoders Metting", dueDate: "05/24/2018"))
        self.todoManager.addItemToTodoList(task: Task(title: "WWDC", dueDate: "06/14/2017"))
        self.todoManager.addItemToTodoList(task: Task(title: "Xcoders Metting", dueDate: "06/21/218"))
        self.todoManager.addItemToTodoList(task: Task(title: "4 of July party!", dueDate: "07/04/2017"))
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let actionSection = ActionSection(rawValue: section) else {fatalError()}
        
        switch actionSection {
        case .Todo:
            return self.todoManager.todoArray.count
        case .Done:
            return self.todoManager.doneArray.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let actionSection = ActionSection(rawValue: section) else { fatalError()}
        
        let sectionTitle:String
        switch actionSection {
        case .Todo:
            sectionTitle = "Todo"
        case .Done:
            sectionTitle = "Done"
        }
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if self.todoManager.todoArray.count == 0  && self.todoManager.doneArray.count == 0 {
            return cell
        }
        guard let actionSection = ActionSection(rawValue: indexPath.section) else {fatalError()}
        let action = actionSection.rawValue == 0 ? self.todoManager.todoListAtIndex(index: indexPath.row) : self.todoManager.actionsDoneAtIndex(index: indexPath.row)
        cell.textLabel?.text = action.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let actionSection = ActionSection(rawValue: indexPath.section) else {fatalError()}
        if actionSection == .Todo{
            self.todoManager.doneTaskAtIndex(index: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
}

class TableViewControllerTest: XCTestCase {
    
    var sut: TableViewController!
    
    override func setUp() {
        super.setUp()
        self.sut = TableViewController()
        _ = self.sut.view
    }
    
    func testTableViewNotNil() {
        XCTAssertNotNil(self.sut.tableView)
    }
    
    func testTableViewDataSourceNotNil() {
        XCTAssertNotNil(self.sut.tableView.dataSource)
    }
    
    func testTableViewDelegatNotNil() {
        XCTAssertNotNil(self.sut.tableView.delegate)
    }
    
    func testTableViewNumberRowsEqualToTwo() {
        let sectionCount = self.sut.tableView.numberOfSections
        XCTAssertEqual(sectionCount, 2)
    }
    
    func testTableViewConformsToTableViewDataSourceProtocol() {
        XCTAssertTrue(self.sut.conforms(to: UITableViewDataSource.self))
        XCTAssertTrue(self.sut.responds(to: #selector(self.sut.numberOfSections(in:))))
        XCTAssertTrue(self.sut.responds(to: #selector(self.sut.tableView(_:numberOfRowsInSection:))))
        XCTAssertTrue(self.sut.responds(to: #selector(self.sut.tableView(_:cellForRowAt:))))
    }
    
    func testTableViewCellHasResubleIdentifier() {
        let cell = self.sut.tableView(self.sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        let actualReuseIdentifer = cell.reuseIdentifier
        let expectedReuseIdentifier = "cell"
        XCTAssertEqual(actualReuseIdentifer, expectedReuseIdentifier)
    }
    
    func testTableViewSectionTitleShowingCorrectTitle() {
        let sectionOneTitle = self.sut.tableView.dataSource?.tableView!(self.sut.tableView, titleForHeaderInSection: 0)
        let sectionTwoTitle = self.sut.tableView.dataSource?.tableView!(self.sut.tableView, titleForHeaderInSection: 1)
        XCTAssertEqual(sectionOneTitle, "Todo")
        XCTAssertEqual(sectionTwoTitle, "Done")
    }
    
    func testTodoListCheckOutToBeDoneList() {
        let titleOne = "Xcoders Meeting"
        let dueDateOne = "05/24/2018"
        let titleTwo = "WWDC"
        let dueDateTwo = "06/04/2018"
        self.sut.todoManager.addItemToTodoList(task: Task(title: titleOne, dueDate: dueDateOne))
        self.sut.todoManager.addItemToTodoList(task: Task(title: titleTwo, dueDate: dueDateTwo))
        self.sut.tableView.reloadData()
        self.sut.tableView.delegate?.tableView!(self.sut.tableView, didSelectRowAt: IndexPath(row:0,section:0))
        XCTAssertEqual(self.sut.todoManager.todoArray.count, 1)
        XCTAssertEqual(self.sut.todoManager.doneArray.count, 1)
        XCTAssertEqual(self.sut.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(self.sut.tableView.numberOfRows(inSection: 1), 1)
    }
    
}

class TaskManager {
    var todoArray = [Task]()
    var doneArray = [Task]()
    
    func addItemToTodoList(task: Task){
        self.todoArray.append(task)
    }
    
    func todoListAtIndex(index: Int) -> Task {
        return self.todoArray[index]
    }
    
    func doneTaskAtIndex(index: Int) {
        guard index < self.todoArray.count else {return}
        let doneAction = self.todoArray.remove(at: index)
        self.doneArray.append(doneAction)
    }
    
    func actionsDoneAtIndex(index: Int) -> Task {
        return self.doneArray[index]
    }
}

class TaskManagerTest: XCTestCase{
    var sut: TaskManager!
    
    override func setUp() {
        super.setUp()
        self.sut = TaskManager()
    }
    
    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }
    
    func testToDoCountShouldBeZero() {
        XCTAssertEqual(self.sut.todoArray.count, 0)
    }
    
    func testTaskDoneCountShouldBeZero() {
        XCTAssertEqual(self.sut.doneArray.count, 0)
    }
    
    func testAddtaskToTodoArrayShouldBeOne() {
        let title = "Xcoders Meeting"
        let dueDateOne = "05/24/2018"
        self.sut.addItemToTodoList(task: Task(title: title, dueDate: dueDateOne))
        XCTAssertEqual(self.sut.todoArray.count, 1)
    }
    
    func testTodoListAtIndexReturnLastTodoTask() {
        let title = "Xcoders Meeting"
        let todo = Task(title: title)
        self.sut.addItemToTodoList(task: todo)
        let returnedTodoItemAtIndex = self.sut.todoListAtIndex(index:0)
        XCTAssertEqual(todo.title, returnedTodoItemAtIndex.title)
    }
    
    func testTodoListUpdateDoneTaskDone() {
        let title = "Xcoders Meeting"
        let dueDateOne = "05/24/2018"
        self.sut.addItemToTodoList(task: Task(title: title, dueDate: dueDateOne))
        self.sut.doneTaskAtIndex(index:0)
        XCTAssertEqual(self.sut.doneArray.count, 1)
        XCTAssertEqual(self.sut.todoArray.count, 0)
    }
    
    func testDoneTaskShouldBeRemoveFromTodoArray() {
        let todoOne = Task(title: "Xcoders Meeting")
        let todoTwo = Task(title: "WWDC")
        self.sut.addItemToTodoList(task: todoOne)
        self.sut.addItemToTodoList(task: todoTwo)
        self.sut.doneTaskAtIndex(index: 0)
        XCTAssertEqual(self.sut.todoListAtIndex(index: 0).title, todoTwo.title)
        XCTAssertEqual(self.sut.actionsDoneAtIndex(index: 0).title, todoOne.title)
    }
}

struct Task: Equatable{
    let title: String
    let dueDate: String?
    
    init(title: String, dueDate: String? = nil) {
        self.title = title
        self.dueDate = dueDate
    }
    
    static func ==(lhs:Task, rhs:Task) -> Bool{
        if lhs.title != rhs.title{
            return false
        }
        if lhs.dueDate != rhs.dueDate {
            return false
        }
        return true
    }
}

class TaskTest: XCTestCase{
    
    func testAddTaskWithTitle() {
        let title = "Xcoders Meeting"
        let task = Task(title: title)
        XCTAssertEqual(task.title, title)
    }
    
    func testTaksAreEqual() {
        let title = "Xcoders Meeting"
        let todoOne = Task(title: title)
        let todoTwo = Task(title: title)
        XCTAssertEqual(todoOne.title, todoTwo.title)
    }
    
    func testTaskWithTitleAndDueDate() {
        let title = "Xcoders Meeting"
        let dueDate = "05/24/2018"
        let todo = Task(title: title, dueDate: dueDate)
        XCTAssertEqual(todo.dueDate, dueDate)
        XCTAssertEqual(todo.title, title)
    }
    
    func testTaskWithSameTitleAndDifferentDueDate() {
        let title = "Xcoders Meeting"
        let dueDateOne = "05/24/2018"
        let dueDateTwo = "06/22/2018"
        let todoOne = Task(title: title, dueDate: dueDateOne)
        let todoTwo = Task(title: title, dueDate: dueDateTwo)
        XCTAssertNotEqual(todoOne, todoTwo)
    }
}

class TestObserver: NSObject, XCTestObservation{
    
    func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        print("😡: \(description) line:\(lineNumber)")
    }
    
    func testCaseDidFinish(_ testCase: XCTestCase) {
        if testCase.testRun?.hasSucceeded == true{
            print("😇 \(testCase)")
        }
    }
}

let observer = TestObserver()
XCTestObservationCenter.shared.addTestObserver(observer)
TaskTest.defaultTestSuite.run()
TaskManagerTest.defaultTestSuite.run()
TableViewControllerTest.defaultTestSuite.run()
PlaygroundPage.current.liveView = TableViewController()
