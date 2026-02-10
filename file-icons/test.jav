import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class StudentRegistry {
    private List<Student> students = new ArrayList<>();

    public void addStudent(String name, int age, double gpa) {
        students.add(new Student(name, age, gpa));
    }

    public List<Student> getHonorRoll() {
        return students.stream()
                .filter(s -> s.getGpa() >= 3.5)
                .sorted((a, b) -> Double.compare(b.getGpa(), a.getGpa()))
                .collect(Collectors.toList());
    }

    public double getAverageGpa() {
        return students.stream()
                .mapToDouble(Student::getGpa)
                .average()
                .orElse(0.0);
    }
}
