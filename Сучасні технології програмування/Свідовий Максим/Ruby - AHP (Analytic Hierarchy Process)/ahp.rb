#!/usr/bin/env ruby
# frozen_string_literal: true

# Analytic Hierarchy Process (AHP) Decision Support Tool
# Discipline: Modern Programming Technologies
# Specialty: Systems Analysis
#
# Консольний застосунок на Ruby для ранжування проєктів
# за допомогою методу аналізу ієрархій (AHP).

# Модель критерію
class Criterion
  attr_accessor :id, :name, :weight

  def initialize(id, name)
    @id = id
    @name = name
    @weight = 0.0
  end
end

# Модель альтернативи
class Alternative
  attr_accessor :id, :name, :global_score, :local_scores

  def initialize(id, name)
    @id = id
    @name = name
    @global_score = 0.0
    # local_scores[criterion_id] = локальний пріоритет під цим критерієм
    @local_scores = {}
  end
end

# Клас для роботи з AHP
class AHP
  # pairwise_matrices:
  # {
  #   :criteria => [[...],[...],...],
  #   :alternatives => {
  #     "C1" => [[...],[...],...],
  #     "C2" => ...
  #   }
  # }
  def initialize(criteria, alternatives, pairwise_matrices)
    @criteria = criteria
    @alternatives = alternatives
    @pairwise_matrices = pairwise_matrices
  end

  # Основний алгоритм
  def run
    puts "=== Analytic Hierarchy Process (AHP) ==="
    puts

    # 1. Ваги критеріїв
    criteria_matrix = @pairwise_matrices[:criteria]
    criteria_weights = priority_vector(criteria_matrix)

    @criteria.each_with_index do |crit, i|
      crit.weight = criteria_weights[i]
    end

    puts "Крок 1. Ваги критеріїв:"
    @criteria.each do |c|
      puts "  #{c.id} (#{c.name}): #{format('%.4f', c.weight)}"
    end
    puts

    # 2. Локальні пріоритети альтернатив під кожним критерієм
    puts "Крок 2. Локальні пріоритети альтернатив за кожним критерієм:"
    @criteria.each do |crit|
      matrix = @pairwise_matrices[:alternatives][crit.id]
      local_pr = priority_vector(matrix)

      puts "  Критерій #{crit.id} (#{crit.name}):"
      @alternatives.each_with_index do |alt, idx|
        alt.local_scores[crit.id] = local_pr[idx]
        puts "    #{alt.id} (#{alt.name}): #{format('%.4f', alt.local_scores[crit.id])}"
      end
      puts
    end

    # 3. Глобальні пріоритети альтернатив (зважена сума)
    puts "Крок 3. Глобальні пріоритети альтернатив:"
    @alternatives.each do |alt|
      score = 0.0
      @criteria.each do |crit|
        w = crit.weight
        l = alt.local_scores[crit.id] || 0.0
        score += w * l
      end
      alt.global_score = score
    end

    # Сортуємо альтернативи за спаданням
    sorted = @alternatives.sort_by { |a| -a.global_score }

    sorted.each_with_index do |alt, rank|
      puts "  #{rank + 1}. #{alt.id} (#{alt.name}) => #{format('%.4f', alt.global_score)}"
    end

    best = sorted.first
    puts
    puts "Найкраща альтернатива за AHP: #{best.id} (#{best.name})"
    puts "З рейтингом: #{format('%.4f', best.global_score)}"
  end

  private

  # Обчислення вектора пріоритетів з матриці парних порівнянь
  # Використано "наближення через нормування стовпців + середнє по рядках".
  #
  # matrix: Array<Array<Float>>
  # Повертає: Array<Float> (нормований вектор, сума ≈ 1)
  def priority_vector(matrix)
    n = matrix.size
    raise "Матриця має бути квадратною" unless n.positive? && matrix.all? { |row| row.size == n }

    # 1. Сума кожного стовпця
    col_sums = Array.new(n, 0.0)
    n.times do |j|
      n.times do |i|
        col_sums[j] += matrix[i][j].to_f
      end
    end

    # 2. Нормування кожного елемента: a_ij / sum_j
    normalized = Array.new(n) { Array.new(n, 0.0) }
    n.times do |i|
      n.times do |j|
        normalized[i][j] = matrix[i][j] / (col_sums[j].zero? ? 1.0 : col_sums[j])
      end
    end

    # 3. Вектор пріоритетів: середні по рядках
    priorities = Array.new(n, 0.0)
    n.times do |i|
      row_sum = normalized[i].reduce(0.0, :+)
      priorities[i] = row_sum / n.to_f
    end

    # 4. Нормалізація, щоб сума = 1 (на всякий випадок)
    total = priorities.reduce(0.0, :+)
    if total.zero?
      # якщо щось пішло не так, повертаємо рівномірний розподіл
      Array.new(n, 1.0 / n)
    else
      priorities.map { |p| p / total }
    end
  end
end

#  Приклад задачі AHP

# Критерії:
# C1 - Expected Profit
# C2 - Risk
# C3 - Project Duration
criteria = [
  Criterion.new("C1", "Expected Profit"),
  Criterion.new("C2", "Risk"),
  Criterion.new("C3", "Project Duration")
]

# Альтернативи: 3 проєкти
alternatives = [
  Alternative.new("A", "Project A"),
  Alternative.new("B", "Project B"),
  Alternative.new("C", "Project C")
]

# --- Матриця парних порівнянь критеріїв ---
#
#    C1   C2   C3
# C1 1    3    4
# C2 1/3  1    2
# C3 1/4  1/2  1
#
criteria_matrix = [
  [1.0,   3.0, 4.0],
  [1.0 / 3.0, 1.0, 2.0],
  [1.0 / 4.0, 1.0 / 2.0, 1.0]
]

# --- Матриці парних порівнянь альтернатив за кожним критерієм ---
#
# Для прикладу беремо довільні, але "адекватні" значення AHP-шкали.

# За критерієм C1 (Expected Profit):
# A проти B: A трохи кращий (3), A проти C: C суттєво кращий (1/5), ...
c1_alternatives_matrix = [
  [1.0,   3.0, 1.0 / 5.0], # A vs A,B,C
  [1.0 / 3.0, 1.0, 1.0 / 7.0], # B vs A,B,C
  [5.0, 7.0, 1.0] # C vs A,B,C
]

# За критерієм C2 (Risk) – менший ризик краще.
# Припустимо, що A має найменший ризик, C – найбільший.
c2_alternatives_matrix = [
  [1.0,  4.0, 7.0],
  [1.0 / 4.0, 1.0, 3.0],
  [1.0 / 7.0, 1.0 / 3.0, 1.0]
]

# За критерієм C3 (Project Duration) – менший термін краще.
# Припустимо, B – найшвидший, A – середній, C – найдовший.
c3_alternatives_matrix = [
  [1.0,     1.0 / 3.0, 3.0],
  [3.0,     1.0,       5.0],
  [1.0 / 3.0, 1.0 / 5.0, 1.0]
]

pairwise_matrices = {
  criteria: criteria_matrix,
  alternatives: {
    "C1" => c1_alternatives_matrix,
    "C2" => c2_alternatives_matrix,
    "C3" => c3_alternatives_matrix
  }
}

# Запуск AHP
ahp = AHP.new(criteria, alternatives, pairwise_matrices)
ahp.run
