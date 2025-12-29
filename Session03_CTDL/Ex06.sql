use ss03;

create table score(
student_id char(10) not null,
subject_id char(10) not null,
mid_score float check(mid_score >= 0 and mid_score <= 10),
final_score float check(final_score >= 0 and final_score <= 10),
primary key(student_id, subject_id),
foreign key(student_id) references student(student_id),
foreign key(subject_id) references subject(subject_id)
);

insert into score values
('SV001','MH001',7.5,8.0),
('SV001','MH002',6.5,7.0),
('SV002','MH001',8.0,9.0);

update score
set final_score = 9.5
where student_id = 'SV001' and subject_id = 'MH001';

select * from score;

select * from score
where final_score >= 8;
