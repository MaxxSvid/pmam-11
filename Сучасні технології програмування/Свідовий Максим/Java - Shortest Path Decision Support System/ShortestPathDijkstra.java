import java.util.*;

/**
 * Shortest Path Decision Support System Using Dijkstra's Algorithm
 * Discipline: Modern Programming Technologies
 * Specialty: Systems Analysis
 *
 * Консольний застосунок для пошуку найкоротшого маршруту між вершинами графа.
 */
public class ShortestPathDijkstra {

    /**
     * Клас, що представляє орієнтований зважений граф.
     */
    static class Graph {
        // adjacencyList: вершина -> список (сусід, вага)
        private final Map<String, List<Edge>> adjacencyList = new HashMap<>();

        /**
         * Додає вершину, якщо її ще немає.
         */
        public void addVertex(String name) {
            adjacencyList.putIfAbsent(name, new ArrayList<>());
        }

        /**
         * Додає орієнтоване ребро з вершини from в вершину to з вагою weight.
         */
        public void addEdge(String from, String to, double weight) {
            addVertex(from);
            addVertex(to);
            adjacencyList.get(from).add(new Edge(to, weight));
        }

        public Set<String> getVertices() {
            return adjacencyList.keySet();
        }

        public List<Edge> getNeighbors(String vertex) {
            return adjacencyList.getOrDefault(vertex, new ArrayList<>());
        }
    }

    /**
     * Ребро графа (кінцева вершина + вага).
     */
    static class Edge {
        String to;
        double weight;

        public Edge(String to, double weight) {
            this.to = to;
            this.weight = weight;
        }
    }

    /**
     * Результат роботи алгоритму Дейкстри –
     * відстані й попередники для відновлення шляху.
     */
    static class DijkstraResult {
        Map<String, Double> distance;
        Map<String, String> previous;

        public DijkstraResult(Map<String, Double> distance, Map<String, String> previous) {
            this.distance = distance;
            this.previous = previous;
        }
    }

    /**
     * Алгоритм Дейкстри: найкоротші відстані від start до всіх інших.
     */
    public static DijkstraResult dijkstra(Graph graph, String start) {
        Map<String, Double> dist = new HashMap<>();
        Map<String, String> prev = new HashMap<>();

        // Ініціалізація: нескінченність для всіх, 0 для старту
        for (String v : graph.getVertices()) {
            dist.put(v, Double.POSITIVE_INFINITY);
            prev.put(v, null);
        }
        dist.put(start, 0.0);

        // Пріоритетна черга (мін-купа) за поточною дистанцією
        PriorityQueue<String> queue = new PriorityQueue<>(Comparator.comparingDouble(dist::get));
        queue.add(start);

        while (!queue.isEmpty()) {
            String current = queue.poll();

            for (Edge edge : graph.getNeighbors(current)) {
                String neighbor = edge.to;
                double newDist = dist.get(current) + edge.weight;

                if (newDist < dist.get(neighbor)) {
                    dist.put(neighbor, newDist);
                    prev.put(neighbor, current);
                    queue.remove(neighbor); // оновлюємо позицію в черзі
                    queue.add(neighbor);
                }
            }
        }

        return new DijkstraResult(dist, prev);
    }

    /**
     * Відновлення шляху з карти попередників.
     */
    public static List<String> reconstructPath(String start, String end, Map<String, String> previous) {
        List<String> path = new ArrayList<>();
        String current = end;

        while (current != null) {
            path.add(current);
            if (current.equals(start)) break;
            current = previous.get(current);
        }

        Collections.reverse(path);

        if (!path.isEmpty() && path.get(0).equals(start)) {
            return path;
        } else {
            // шляху немає
            return Collections.emptyList();
        }
    }

    /**
     * Створення демонстраційного графа.
     */
    public static Graph buildSampleGraph() {
        Graph graph = new Graph();

        // Приклад: міста як вершини
        // Ваги – умовні відстані / вартість / час
        graph.addEdge("A", "B", 5);
        graph.addEdge("A", "C", 10);
        graph.addEdge("B", "C", 3);
        graph.addEdge("B", "D", 9);
        graph.addEdge("C", "D", 1);
        graph.addEdge("C", "E", 7);
        graph.addEdge("D", "E", 2);
        graph.addEdge("E", "F", 4);
        graph.addEdge("B", "F", 20);

        // Для неорієнтованого графа можна додати зворотні ребра:
        graph.addEdge("B", "A", 5);
        graph.addEdge("C", "A", 10);
        graph.addEdge("C", "B", 3);
        graph.addEdge("D", "B", 9);
        graph.addEdge("D", "C", 1);
        graph.addEdge("E", "C", 7);
        graph.addEdge("E", "D", 2);
        graph.addEdge("F", "E", 4);
        graph.addEdge("F", "B", 20);

        return graph;
    }

    /**
     * Головний метод: консольний інтерфейс.
     */
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        Graph graph = buildSampleGraph();

        System.out.println("===== Shortest Path Decision Support System (Dijkstra) =====");
        System.out.println("Available vertices (cities): ");
        for (String v : graph.getVertices()) {
            System.out.print(v + " ");
        }
        System.out.println();
        System.out.println("-------------------------------------------------------------");

        System.out.print("Enter START vertex (e.g., A): ");
        String start = scanner.nextLine().trim();

        System.out.print("Enter END vertex (e.g., F): ");
        String end = scanner.nextLine().trim();

        if (!graph.getVertices().contains(start) || !graph.getVertices().contains(end)) {
            System.out.println("One of the vertices does not exist in the graph.");
            return;
        }

        DijkstraResult result = dijkstra(graph, start);
        List<String> path = reconstructPath(start, end, result.previous);

        System.out.println();
        if (path.isEmpty()) {
            System.out.println("No path found from " + start + " to " + end + ".");
        } else {
            System.out.println("Shortest path from " + start + " to " + end + ": " + path);
            System.out.printf("Total distance: %.2f%n", result.distance.get(end));
        }

        System.out.println("-------------------------------------------------------------");
        System.out.println("Distances from start vertex " + start + " to all vertices:");
        for (String v : graph.getVertices()) {
            double d = result.distance.get(v);
            System.out.printf("%s -> %s : %s%n", start, v,
                    d == Double.POSITIVE_INFINITY ? "unreachable" : String.format("%.2f", d));
        }
    }
}
