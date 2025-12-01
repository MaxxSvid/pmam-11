using System;
using System.Globalization;

namespace QueueSystemAnalysis
{
    /// <summary>
    /// Модель простої системи масового обслуговування типу M/M/1.
    /// </summary>
    public class MM1Queue
    {
        public double Lambda { get; private set; }   // Інтенсивність надходження (заявок/од. часу)
        public double Mu { get; private set; }       // Інтенсивність обслуговування (заявок/од. часу)

        public double Rho { get; private set; }      // Завантаження системи
        public double L { get; private set; }        // Середня кількість заявок в системі
        public double Lq { get; private set; }       // Середня кількість заявок в черзі
        public double W { get; private set; }        // Середній час перебування в системі
        public double Wq { get; private set; }       // Середній час очікування в черзі
        public double P0 { get; private set; }       // Імовірність, що в системі 0 заявок

        public MM1Queue(double lambda, double mu)
        {
            Lambda = lambda;
            Mu = mu;
        }

        /// <summary>
        /// Перевірка стійкості системи (rho < 1).
        /// </summary>
        public bool IsStable()
        {
            if (Mu <= 0) return false;
            return Lambda / Mu < 1.0;
        }

        /// <summary>
        /// Обчислення показників M/M/1.
        /// </summary>
        public void Compute()
        {
            if (!IsStable())
            {
                throw new InvalidOperationException("Система нестійка: λ/μ ≥ 1. Задайте інші параметри.");
            }

            Rho = Lambda / Mu;
            L = Rho / (1.0 - Rho);
            Lq = (Math.Pow(Rho, 2)) / (1.0 - Rho);
            W = L / Lambda;
            Wq = Lq / Lambda;
            P0 = 1.0 - Rho;
        }

        /// <summary>
        /// Вивід звіту в консоль.
        /// </summary>
        public void PrintReport(string title = null)
        {
            if (!string.IsNullOrEmpty(title))
            {
                Console.WriteLine("==== " + title + " ====");
            }

            Console.WriteLine($"Lambda (λ) = {Lambda:F3}");
            Console.WriteLine($"Mu (μ)      = {Mu:F3}");
            Console.WriteLine($"Rho (ρ)     = {Rho:F3}  (завантаження системи)");
            Console.WriteLine($"P0          = {P0:F3}  (ймовірність, що система порожня)");
            Console.WriteLine($"L           = {L:F3}   (середня кількість заявок у системі)");
            Console.WriteLine($"Lq          = {Lq:F3}  (середня кількість заявок у черзі)");
            Console.WriteLine($"W           = {W:F3}   (середній час в системі)");
            Console.WriteLine($"Wq          = {Wq:F3}  (середній час в черзі)");
            Console.WriteLine(new string('-', 50));
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            Console.OutputEncoding = System.Text.Encoding.UTF8;
            CultureInfo.CurrentCulture = CultureInfo.InvariantCulture;

            while (true)
            {
                PrintMenu();
                Console.Write("Оберіть пункт меню: ");
                string choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                        SingleScenario();
                        break;
                    case "2":
                        CompareScenarios();
                        break;
                    case "3":
                        Console.WriteLine("Вихід з програми.");
                        return;
                    default:
                        Console.WriteLine("Невірний вибір. Спробуйте ще раз.\n");
                        break;
                }
            }
        }

        /// <summary>
        /// Вивід головного меню.
        /// </summary>
        static void PrintMenu()
        {
            Console.WriteLine("===============================================");
            Console.WriteLine(" Queue System Performance Calculator (M/M/1) ");
            Console.WriteLine(" Сучасні технології програмування – C#");
            Console.WriteLine("===============================================");
            Console.WriteLine("1. Аналіз однієї системи M/M/1");
            Console.WriteLine("2. Порівняння двох сценаріїв");
            Console.WriteLine("3. Вихід");
            Console.WriteLine("===============================================");
        }

        /// <summary>
        /// Зчитування числа з консолі з підказкою.
        /// </summary>
        static double ReadDouble(string prompt)
        {
            while (true)
            {
                Console.Write(prompt);
                string input = Console.ReadLine();

                if (double.TryParse(input, NumberStyles.Any, CultureInfo.InvariantCulture, out double value)
                    && value > 0)
                {
                    return value;
                }

                Console.WriteLine("Помилка вводу. Введіть додатне число (наприклад, 3.5).");
            }
        }

        /// <summary>
        /// Аналіз одного сценарію черги.
        /// </summary>
        static void SingleScenario()
        {
            Console.WriteLine("\n--- Аналіз однієї системи M/M/1 ---");
            double lambda = ReadDouble("Введіть інтенсивність надходження λ (заявок/год): ");
            double mu = ReadDouble("Введіть інтенсивність обслуговування μ (заявок/год): ");

            var queue = new MM1Queue(lambda, mu);

            if (!queue.IsStable())
            {
                Console.WriteLine("Система нестійка (λ/μ ≥ 1). Задайте інші значення.\n");
                return;
            }

            queue.Compute();
            queue.PrintReport("Результати аналізу системи");
        }

        /// <summary>
        /// Порівняння двох сценаріїв (наприклад, до та після покращення сервісу).
        /// </summary>
        static void CompareScenarios()
        {
            Console.WriteLine("\n--- Порівняння двох сценаріїв M/M/1 ---");

            Console.WriteLine("Сценарій 1:");
            double lambda1 = ReadDouble("λ1: ");
            double mu1 = ReadDouble("μ1: ");

            Console.WriteLine("\nСценарій 2:");
            double lambda2 = ReadDouble("λ2: ");
            double mu2 = ReadDouble("μ2: ");

            var q1 = new MM1Queue(lambda1, mu1);
            var q2 = new MM1Queue(lambda2, mu2);

            try
            {
                if (!q1.IsStable() || !q2.IsStable())
                {
                    Console.WriteLine("Один із сценаріїв нестійкий (λ/μ ≥ 1). Перевірте введені дані.\n");
                    return;
                }

                q1.Compute();
                q2.Compute();

                Console.WriteLine();
                q1.PrintReport("Сценарій 1");
                q2.PrintReport("Сценарій 2");

                Console.WriteLine("Порівняння середньої кількості заявок у системі (L):");
                Console.WriteLine($"L1 = {q1.L:F3}, L2 = {q2.L:F3}");
                Console.WriteLine("Порівняння середнього часу в системі (W):");
                Console.WriteLine($"W1 = {q1.W:F3}, W2 = {q2.W:F3}");
                Console.WriteLine();
            }
            catch (Exception ex)
            {
                Console.WriteLine("Помилка обчислень: " + ex.Message + "\n");
            }
        }
    }
}
