import numpy as np
import sys
from dataclasses import dataclass
from typing import List, Dict



# 1. МОДЕЛІ ДАНИХ


@dataclass
class Criterion:
    """Критерій багатокритеріальної задачі"""
    id: str
    name: str
    weight: float
    type: str  # 'benefit' або 'cost'


@dataclass
class Alternative:
    """Альтернатива (проєкт, варіант рішення)"""
    name: str
    values: Dict[str, float]
    score: float = 0.0
    distance_to_ideal: float = 0.0
    distance_to_anti_ideal: float = 0.0


# 2. КЛАС РЕАЛІЗАЦІЇ TOPSIS

class TOPSIS:
    def __init__(self, criteria: List[Criterion], alternatives: List[Alternative]):
        self.criteria = criteria
        self.alternatives = alternatives
        self.normalized_matrix = {}
        self.weighted_matrix = {}

    def log(self, msg):
        print(f"[LOG] {msg}")

    def normalize_matrix(self):
        """Нормуємо значення альтернатив по кожному критерію"""
        self.log("Нормалізація матриці...")

        # Підготовка структури
        for alt in self.alternatives:
            self.normalized_matrix[alt.name] = {}

        # Вектор нормування (корінь суми квадратів)
        for crit in self.criteria:
            sq_sum = sum((alt.values[crit.id] ** 2 for alt in self.alternatives))
            denom = np.sqrt(sq_sum)

            for alt in self.alternatives:
                self.normalized_matrix[alt.name][crit.id] = alt.values[crit.id] / denom

        self.log("Матриця нормована.")

    def apply_weights(self):
        """Застосовуємо ваги до нормованої матриці"""
        self.log("Зважування матриці критеріїв...")

        for alt in self.alternatives:
            self.weighted_matrix[alt.name] = {}

        for crit in self.criteria:
            for alt in self.alternatives:
                base = self.normalized_matrix[alt.name][crit.id]
                self.weighted_matrix[alt.name][crit.id] = base * crit.weight

        self.log("Застосовано ваги до нормованих значень.")

    def get_ideal_solutions(self):
        """Будуємо ідеальний та антиідеальний розв’язок"""
        ideal = {}
        anti_ideal = {}

        for crit in self.criteria:
            values = [self.weighted_matrix[a.name][crit.id] for a in self.alternatives]

            if crit.type == "benefit":
                ideal[crit.id] = max(values)
                anti_ideal[crit.id] = min(values)
            else:
                ideal[crit.id] = min(values)
                anti_ideal[crit.id] = max(values)

        return ideal, anti_ideal

    def calculate_distances(self, ideal, anti_ideal):
        """Обчислюємо відстані альтернатив до ідеального та антиідеального"""
        for alt in self.alternatives:
            dist_pos = 0
            dist_neg = 0

            for crit in self.criteria:
                value = self.weighted_matrix[alt.name][crit.id]

                dist_pos += (value - ideal[crit.id]) ** 2
                dist_neg += (value - anti_ideal[crit.id]) ** 2

            alt.distance_to_ideal = np.sqrt(dist_pos)
            alt.distance_to_anti_ideal = np.sqrt(dist_neg)

    def calculate_scores(self):
        """Фінальна оцінка (кількість близькості до ідеалу)"""
        for alt in self.alternatives:
            alt.score = alt.distance_to_anti_ideal / (
                alt.distance_to_ideal + alt.distance_to_anti_ideal
            )

    def run(self):
        """Запуск повного алгоритму TOPSIS"""
        self.normalize_matrix()
        self.apply_weights()

        ideal, anti_ideal = self.get_ideal_solutions()
        self.log(f"Ідеальний розв’язок: {ideal}")
        self.log(f"Антиідеальний розв’язок: {anti_ideal}")

        self.calculate_distances(ideal, anti_ideal)
        self.calculate_scores()

        # Сортування
        self.alternatives.sort(key=lambda x: x.score, reverse=True)

        self.log("Обчислення завершено.\n")
        return self.alternatives


# 3. ПРИКЛАД РОБОТИ

def example():
    criteria = [
        Criterion("C1", "Очікуваний прибуток", 0.4, "benefit"),
        Criterion("C2", "Тривалість проєкту", 0.2, "cost"),
        Criterion("C3", "Рівень ризику", 0.2, "cost"),
        Criterion("C4", "Стратегічна важливість", 0.2, "benefit"),
    ]

    alternatives = [
        Alternative("Проєкт A", {"C1": 120, "C2": 10, "C3": 6, "C4": 8}),
        Alternative("Проєкт B", {"C1": 90, "C2": 7, "C3": 4, "C4": 6}),
        Alternative("Проєкт C", {"C1": 150, "C2": 14, "C3": 8, "C4": 9}),
        Alternative("Проєкт D", {"C1": 80, "C2": 6, "C3": 3, "C4": 5}),
    ]

    model = TOPSIS(criteria, alternatives)
    results = model.run()

    print("================= РЕЗУЛЬТАТИ =================")
    for i, alt in enumerate(results, start=1):
        print(
            f"{i}. {alt.name}: score={alt.score:.4f}, "
            f"d+={alt.distance_to_ideal:.3f}, d-={alt.distance_to_anti_ideal:.3f}"
        )


# 4. ЗАПУСК

if __name__ == "__main__":
    example()

