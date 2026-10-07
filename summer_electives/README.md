# Summer Electives: Normalized Schema

The Registrar's master summer electives spreadsheet has **998 rows × 650 columns**:

* 6 descriptive columns: `student_id, first_name, last_name, discipline, campus_name, Term & Academic Year`
* 644 course columns named `CODE+Title` (e.g. `MGT-606+Operations Management`), each holding a grade or left blank

Almost every cell is blank (641,530 of 642,712 course cells). Only **1,182** hold a grade.

## Problems in the original sheet

| Problem | Example | Normal form broken |
|---|---|---|
| Repeating group: one column per course | 644 course columns, 1–4 filled per row | 1NF |
| Non-atomic column headers | `MGT-606+Operations Management` holds both code and title | 1NF |
| Non-atomic term value | `Summer AY12-13` holds season and academic year | 1NF |
| Student name repeated on every row | student `23522` appears on 6 rows | 2NF (name depends on `student_id` only) |
| Discipline repeated per row | `discipline` is determined by the course (checked: each of the 139 courses taken maps to exactly one discipline) | 3NF (transitive: row → course → discipline) |
| Free-text campus/term/grade values | `'Virtual - Eurasia (London Timezone)'` typed on every row | redundancy / update anomalies |

## Normalized design (3NF)

```
student (student_id PK, first_name, last_name)
discipline (discipline_id PK, discipline_name UNIQUE)
campus (campus_id PK, campus_name UNIQUE)
term (term_id PK, term_name UNIQUE, season, academic_year, start_year)
grade (grade_code PK, description, grade_points)
course (course_code PK, course_title, subject_code, discipline_id FK → discipline)

enrollment (enrollment_id PK,
            student_id FK → student,
            course_code FK → course,
            term_id FK → term,
            campus_id FK → campus,
            grade_code FK → grade,
            UNIQUE (student_id, course_code, term_id))
```

```
student 1───* enrollment *───1 course *───1 discipline
                   │ * │ *
                   │   └──1 term
                   │ *
                   ├──1 campus
                   └──1 grade
```

Why `campus` lives on `enrollment` and not on `student`: 70 students took courses at more than one campus, sometimes in the same term (e.g. student 78: London and Sao Paulo in Summer AY12-13). So campus belongs to the enrollment, not to the student.

### Resulting row counts

| Table | Rows |
|---|---|
| student | 423 |
| discipline | 17 |
| campus | 9 |
| term | 12 |
| grade | 16 |
| course | 644 (139 have enrollments; the other 505 have `discipline_id = NULL` because the sheet never shows their discipline) |
| enrollment | 1,182 |

Verified: joining the tables back together reproduces every non-blank grade cell of the original CSV exactly (1,182 of 1,182).

## Files

* `summer_electives_normalized.sql`: creates database `summer_electives`, all 7 tables, and inserts all data. Run it in MySQL Workbench (or `mysql < summer_electives_normalized.sql`).
* `build_normalized.py`: regenerates the SQL from the CSV: `python3 build_normalized.py registrar.csv summer_electives_normalized.sql`

## Example queries

```sql
USE summer_electives;

-- Rebuild the original (long-format) view
SELECT e.student_id, s.first_name, s.last_name, d.discipline_name,
       ca.campus_name, t.term_name, c.course_code, c.course_title, e.grade_code
FROM enrollment e
JOIN student    s  ON s.student_id    = e.student_id
JOIN course     c  ON c.course_code   = e.course_code
JOIN discipline d  ON d.discipline_id = c.discipline_id
JOIN campus     ca ON ca.campus_id    = e.campus_id
JOIN term       t  ON t.term_id       = e.term_id;

-- Enrollments per campus per academic year
SELECT ca.campus_name, t.academic_year, COUNT(*) AS enrollments
FROM enrollment e
JOIN campus ca ON ca.campus_id = e.campus_id
JOIN term   t  ON t.term_id    = e.term_id
GROUP BY ca.campus_name, t.academic_year
ORDER BY t.academic_year, enrollments DESC;

-- Most popular electives and average GPA (letter grades only)
SELECT c.course_code, c.course_title, COUNT(*) AS students,
       ROUND(AVG(g.grade_points), 2) AS avg_gpa
FROM enrollment e
JOIN course c ON c.course_code = e.course_code
JOIN grade  g ON g.grade_code  = e.grade_code
GROUP BY c.course_code, c.course_title
ORDER BY students DESC
LIMIT 10;
```

Note: `grade_points` uses a standard 4.0 scale (A = 4.0, A- = 3.7, …). Pass, High Pass, Audit and Incomplete are stored with `NULL` points, so `AVG()` skips them.
