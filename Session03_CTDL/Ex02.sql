use ss03;

create table student(
student_id char(10) primary key,
full_name varchar(50) not null,
date_of_birth date,
email varchar(50) unique
);

insert into student values
('SV001','Nguyen Van A','2004-05-12','a@gmail.com'),
('SV002','Tran Thi B','2004-08-20','b@gmail.com'),
('SV003','Le Van C','2003-12-01','c@gmail.com');

select * from student;

select student_id, full_name from student;
