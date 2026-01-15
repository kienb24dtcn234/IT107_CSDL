DROP DATABASE IF EXISTS UniversityDB;
CREATE DATABASE UniversityDB;
USE UniversityDB;

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(50)
);

CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100),
    available_seats INT
);

CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enroll_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO students (student_name) VALUES
('Nguyễn Văn An'),
('Trần Thị Bình');

INSERT INTO courses (course_name, available_seats) VALUES
('Cơ sở dữ liệu', 2),
('Lập trình Java', 0);

DELIMITER $$

CREATE PROCEDURE sp_EnrollCourse(
    IN p_student_name VARCHAR(50),
    IN p_course_name VARCHAR(100)
)
BEGIN
    DECLARE v_student_id INT;
    DECLARE v_course_id INT;
    DECLARE v_seats INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT student_id INTO v_student_id
    FROM students
    WHERE student_name = p_student_name;

    SELECT course_id, available_seats
    INTO v_course_id, v_seats
    FROM courses
    WHERE course_name = p_course_name
    FOR UPDATE;

    IF v_seats > 0 THEN
        INSERT INTO enrollments (student_id, course_id)
        VALUES (v_student_id, v_course_id);

        UPDATE courses
        SET available_seats = available_seats - 1
        WHERE course_id = v_course_id;

        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END$$

DELIMITER ;

CALL sp_EnrollCourse('Nguyễn Văn An', 'Cơ sở dữ liệu');
