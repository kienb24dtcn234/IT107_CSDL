use ss03;

create table enrollment(
student_id char(10) not null,
subject_id char(10) not null,
enroll_date date not null,
primary key(student_id, subject_id),
foreign key(student_id) references student(student_id),
foreign key(subject_id) references subject(subject_id)
);

insert into enrollment values
('SV001','MH001','2024-09-01'),
('SV001','MH002','2024-09-02'),
('SV002','MH001','2024-09-01'),
('SV002','MH003','2024-09-03');

select * from enrollment;

select * from enrollment
where student_id = 'SV001';
