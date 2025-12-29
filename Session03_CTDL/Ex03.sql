use ss03;

update student
set email = 'newemail@gmail.com'
where student_id = 3;

update student
set date_of_birth = '2004-01-15'
where student_id = 2;

delete from student
where student_id = 5;

select * from student;
