use ss03;

create table subject(
subject_id char(10) primary key,
subject_name varchar(50) not null,
credit int check(credit > 0)
);

insert into subject values
('MH001','Lap trinh C',3),
('MH002','Co so du lieu',4),
('MH003','Mang may tinh',3);

update subject
set credit = 5
where subject_id = 'MH002';

update subject
set subject_name = 'Lap trinh C nang cao'
where subject_id = 'MH001';
