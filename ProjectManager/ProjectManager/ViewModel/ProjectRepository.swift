import Foundation

class ProjectRepository {
    weak var delegate: ProjectRepositoryDelegate?
    let coreDataManager = CoreDataManager<ProjectData>(entityName: ProjectData.entityName)
    private var selectedProject: Project?
    private var projects: [Project] = [] {
        didSet {
            delegate?.didChangeProject()
        }
    }
    var todoProjects: [Project] {
        projects.filter { $0.state == .todo }
    }
    var doingProjects: [Project] {
        projects.filter { $0.state == .doing }
    }
    var doneProjects: [Project] {
        projects.filter { $0.state == .done }
    }
    
    func fetchProjects() {
        let fetchedData = coreDataManager.fetch(request: ProjectData.fetchRequest()) { error in
            print(error.localizedDescription)
        }
        projects = fetchedData.map { $0.translateToModelType() }
    }
    
    func addProject(projectInput: ProjectInput) {
        let newProject = Project(title: projectInput.title, body: projectInput.body, date: projectInput.date)
        projects.append(newProject)
        coreDataManager.create(values: newProject.dictionary) { error in
            print(error.localizedDescription)
        }
    }
    
    func editProject(with projectInput: ProjectInput) {
        guard let selectedProject = selectedProject,
              let index = projects.firstIndex(where: { $0 == selectedProject }),
              let projectData = searchData(with: selectedProject.id.uuidString).first else { return }
        projects[index].title = projectInput.title
        projects[index].body = projectInput.body
        projects[index].date = projectInput.date
        coreDataManager.update(object: projectData, values: projects[index].dictionary) { error in
            print(error.localizedDescription)
        }
    }
    
    func deleteProject(_ project: Project) {
        guard let index = projects.firstIndex(where: { $0 == project }),
              let projectData = searchData(with: project.id.uuidString).first else { return }
        projects.remove(at: index)
        coreDataManager.delete(data: projectData) { error in
            print(error.localizedDescription)
        }
    }
    
    func changeState(of project: Project?, to state: ProjectState) {
        guard let selectedProject = project,
            let index = projects.firstIndex(where: { $0 == selectedProject }) else { return }
        switch state {
        case .todo:
            projects[index].state = .todo
            changeProjectDataState(with: selectedProject, to: .todo)
        case .doing:
            projects[index].state = .doing
            changeProjectDataState(with: selectedProject, to: .doing)
        case .done:
            projects[index].state = .done
            changeProjectDataState(with: selectedProject, to: .done)
        }
    }
    
    func changeProjectDataState(with project: Project, to state: ProjectState) {
        guard let projectData = searchData(with: project.id.uuidString).first else { return }
        coreDataManager.update(object: projectData, values: ["state": state.title]) { error in
            print(error.localizedDescription)
        }
    }
    
    func setSelectedProject(with project: Project) {
        selectedProject = project
    }
    
    func searchData(with id: String) -> [ProjectData] {
        let searchedProjectData = coreDataManager.search(request: ProjectData.fetchRequest(), id: id) { error in
            print(error.localizedDescription)
        }
        return searchedProjectData
    }
}
