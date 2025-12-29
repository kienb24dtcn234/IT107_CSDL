use ss03;

insert into student values
('SV004','Pham Van D','2004-10-10','d@gmail.com');

insert into enrollment values
('SV004','MH001','2024-09-05'),
('SV004','MH002','2024-09-06');

insert into score values
('SV004','MH001',6.5,7.0),
('SV004','MH002',7.0,8.0);

update score
set final_score = 8.5
where student_id = 'SV004' and subject_id = 'MH001';

delete from enrollment
where student_id = 'SV004' and subject_id = 'MH002';

select s.student_id, s.full_name, sub.subject_name, sc.mid_score, sc.final_score
from student s
join score sc on s.student_id = sc.student_id
join subject sub on sc.subject_id = sub.subject_id;
