import groovy.json.JsonSlurper
import groovy.json.JsonOutput

class UserService {
    List<Map> users = []

    void addUser(String name, String email, String role = 'viewer') {
        users << [name: name, email: email, role: role, createdAt: new Date()]
    }

    List<Map> findByRole(String role) {
        users.findAll { it.role == role }
    }

    String toJson() {
        JsonOutput.prettyPrint(JsonOutput.toJson(users))
    }
}

def service = new UserService()
service.addUser('Alice', 'alice@example.com', 'admin')
service.addUser('Bob', 'bob@example.com', 'editor')
service.addUser('Carol', 'carol@example.com')

println "Admins: ${service.findByRole('admin')*.name}"
println "All users:"
println service.toJson()
