--2.1 Select all records from the Employee table.
select * from employee;

--2.1 Select all records from the Employee table where last name is King.
select * from employee where lastname like 'King';

--2.1 Select all records from the employee table where first name is Andrew and REPORTSTO is NULL.
select * from employee where firstname = 'Andrew' and reportsto is null;

--2.2 select all albums in album table and sort result set in descending order by title.
select title from album order by title desc;

--2.2 select first name from Customer and sort result set in ascending order by city.
select firstname, city from customer order by city asc;

--2.3 Insert two new records into Genre tablw
insert into genre (genreid, name) values ('26','80s'), ('27','Grunge');

--2.3 Insert two new records into Employee table
insert into employee (employeeid, lastname, firstname, title, reportsto, birthdate, hiredate, address, 
	city, state, country, postalcode, phone, fax, email)
	values('9','Smith','Jack','IT Staff','6','1941-04-30 00:00:00','2019-01-24 00:00:00','123 Any St',
	'Anytown','WA', 'United States','98123','(253)460-1234','(253)461-2345','jack@chinookcorp.com'), 
	('10','Jones','Angela','IT Staff','6','1941-04-30 00:00:00','2019-01-24 00:00:00','456 Somewhere St',
	'Pasco','WA', 'United States','99301','(253)460-6789','(253)458-8618','angelak@chinookcorp.com');

--2.3 Insert two new records into Customer table
insert into customer (customerid, firstname, lastname, company, address,
	city, state, country, postalcode, phone, fax, email, supportrepid)
	values('60','Amy','Shannon',null,'695 Main St','Richland','WA','United States','99352','+1(509)946-1234',null,'amy.shannon@gmail.com','3'),
	('61','Steven','Lindenmeier',null,'649 156th St','Kennewick','WA','United States','99336','+1(509)944-5821',null,'steven.lindenmeier@gmail.com','3');

--2.4 Update Aaron Mitchell in Customer table to Robert Walter
update customer set firstname = 'Robert', lastname = 'Walter'
	where firstname = 'Aaron' and lastname = 'Mitchell';

--2.4 update name of artist in the Artist table "Creedence Clearwater Revival" to "CCR"
update artist set name = 'CCR' where name = 'Creedence Clearwater Revival';

--2.5 Select all invoices with a billing address like "T%"
select * from invoice where billingaddress like 'T%';

--2.6 Select all invoices that have a total between 15 and 50
select * from invoice where total between 15 and 50;

--2.6 Select all employees hired between 1st of June 2003 and 1st of March 2004
select firstname, lastname, date(hiredate) from employee 
	where date(hiredate) between '2003-06-01' and '2004-03-01';

--2.7 Delete a record in Customer table where the name is Robert Walter
	--(There may be constraints that rely on this, find out how to resolve them)

--alter child table of child table first
alter table invoiceline
	drop constraint fk_invoicelineinvoiceid;

alter table invoiceline
	add constraint fk_invoicelineinvoiceid
		foreign key (invoiceid)
		references invoice(invoiceid)
		on delete cascade;
	
--alter child table next
alter table invoice
	drop constraint fk_invoicecustomerid;

alter table invoice
	add constraint fk_invoicecustomerid
	foreign key (customerid)
	references customer(customerid)
	on delete cascade;

--delete row from customer table
delete from customer
	where firstname = 'Robert' and lastname = 'Walter';

--3.1 Create a function that returns the curent time
create or replace function getTime()
	returns timestamp as $$
begin
	return now();
end;

$$ language plpgsql;

select getTime();

--3.1 Create a function that returns the length of a mediatype from the mediatype table
create or replace function getLength(id int)
	returns int as $$
begin
	return length(name) from mediatype
		where mediatypeid = id;
end;

$$ language plpgsql;

select getLength(2);

--3.2 Create a function that returns the average total of all invoices
create or replace function avgTotal()
	returns numeric as $$
begin
	return avg(total) from invoice;
end;

$$ language plpgsql;

select avgTotal();

--3.2 Create a function that returns the most expensive track
create or replace function mostExpensiveTrack()
	returns numeric as $$
begin
	return max(track.unitprice) from track;
end;

$$ language plpgsql;

select mostExpensiveTrack();

--3.3 Create a function that returns the average price of invoiceline items in the invoiceline table
create or replace function avgPrice()
	returns numeric as $$
begin
	return avg(unitprice) from invoiceline;
end;

$$ language plpgsql;

select avgPrice();

--3.4 Create a function that returns all employees who are born after 1968
create or replace function bornAfter1968()
	returns setof employee as $$
begin
	return query(select * from employee 
					where extract(year from birthdate) > 1968);
end;

$$ language plpgsql;

select bornAfter1968();


--4.1 Create a procedure that selects the first and last names of all the employees
create or replace function employeeNames(out ref1 refcursor)
	returns refcursor as $$

	begin
		open ref1 for select firstname, lastname from employee;
	end;
$$ language plpgsql;

create table employeeNames(
	employeeid serial primary key,
	firstname text,
	lastname text
);

do $$
declare
	curs refcursor;
	fNameValue text;
	lNameValue text;
begin
	select employeeNames() into curs;
		loop
			fetch curs into fNameValue, lNameValue;
			exit when not found;
			insert into EmployeeNames(firstname, lastname) values(fNameValue, lNameValue);
		end loop;
end;
$$ language plpgsql;

select * from employeeNames;

--4.2 Create a stored procedure that updates the personal information of an employee
create or replace function updateEmployeeInfo(
	empId int, 
	empBirthdate timestamp, 
	empAddress varchar, 
	empCity varchar, 
	empState varchar,
	empCountry varchar,
    empPostalcode varchar,
    empPhone varchar,
    empFax varchar,
   	empEmail varchar
)
returns void as $$		--return void when don't have any out parameters
begin
    update employee
    	set birthdate = empBirthdate,
    	address = empAddress,
    	city =empCity,
    	state = empState,
    	country = empCountry,
    	postalcode = empPostalCode,
    	phone = empPhone,
    	fax = empFax,
    	email = empEmail
        where employeeid = empId;
end;
$$ language plpgsql;

select updateEmployeeInfo(6, '1953-01-01', '123 Main Street', 'Anaheim', 'CA', 'US', '98765', '476-123-4567', null, 'minmouse@gmail.com');
select * from employee

--4.2 Create a stored procedure that returns the managers of an employee
create table e_managers (
	employeeid serial primary key,
	m_name text,
	e_name text
);

create or replace function employeeManagers()
returns refcursor as $$
	declare
		ref refcursor;
	begin
		open ref for select 
			concat(m.firstname, ', ', m.lastname) as "Manager Name",
			concat(e.firstname, ', ', e.lastname) as "Employee Name"
			from employee as m
			inner join employee as e  
			on m.employeeid = e.reportsto
			order by m.employeeid;
		return ref;
	end;
$$ language plpgsql;

do $$
declare
    curs refcursor;
  	v_m_name text;
  	v_e_name text;
begin
    select employeeManagers() into curs;
   	loop
        fetch curs into v_m_name, v_e_name;
        exit when not found;
        insert into e_managers (m_name, e_name) values(v_m_name, v_e_name);
   	end loop;
end;
$$ language plpgsql;

select * from e_managers;

--4.3 Create a stored procedure that returns the name and company of a customer
create table temp_customers (
	id serial primary key,
	name text,
	company text
);

create or replace function getCustomers()
returns refcursor as $$
	declare
		ref refcursor;
	begin
		open ref for select 
			concat(firstname, ' ', lastname),
			company
			from customer
			order by customerid;
		return ref;
	end;
$$ language plpgsql;

do $$
declare
    curs refcursor;
  	v_name text;
  	v_company text;
begin
    select getCustomers() into curs;
   	loop
        fetch curs into v_name, v_company;
        exit when not found;
        insert into temp_customers (name, company) values(v_name, v_company);
   	end loop;
end;
$$ language plpgsql;

select * from temp_customers;

--5.0 Create a transaction that given a invoiceId will delete that invoice 
	--There may be constraints that rely on this, find out how to resolve them
begin;
	delete from invoice where invoiceid = 405;
commit;


--5.0 Create a transaction nested within a stored procedure that inserts a new record in the Customer table


--6.1 Create an after insert trigger on the employee table fired after a new record is inserted into the table
create or replace function hello_world()
returns trigger as $$
	begin
		raise 'Hello, World';
	end;
$$ language plpgsql;

-- Task 1 - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
create trigger after_employee_insert
	after insert on employee
	for each row
    execute procedure hello_world();
   
drop trigger after__employee_insert on employee;

--6.1 Create an after update trigger on the album table that fires after a row is inserted in the table
create trigger after_album_update
	after update on album
	for each row
    execute procedure hello_world();
   
insert into album values (350, 'Testing', 275);
update album set title = 'Updated Title' where albumid = 350;
select * from album;
delete from album where albumid = 350;

drop trigger after_album_update on album;

--6.1 Create an after delete trigger on the customer table that fires after a row is deleted from the table
create trigger after_customer_delete
	after delete on customer
	for each row
    execute procedure hello_world();
   
insert into customer (customerid, firstname, lastname, email) values (62, 'John', 'Doe', 'jd@gmail.com');
select * from customer;
delete from customer where customerid = 62;

drop trigger after_customer_delete on customer;

--7.1 Create an inner join that joins customers and orders 
	--and specifies the name of the customer and the invoiceId
select 
	c.firstname  as "First Name",
	c.lastname as "Last Name", 
	i.invoiceid as "Invoice ID"
from customer as c
inner join invoice as i 
	on c.customerid = i.customerid
	order by c.lastname;

--7.2 Create an outer join that joins the customer and invoice table, 
	--specifying the customerId, firstname, lastname, invoiceId, and total
select 
	c.customerid as "Customer Id", 
	c.firstname as "First Name", 
	c.lastname as "Last Name", 
	i.invoiceid as "Invoice Id", 
	i.total as "Total"
from customer as c
full outer join invoice as i 
on c.customerid = i.customerid;

--7.3 Create a right join that joins album and artist specifying artist name and title
select 
	art.name as "Artist Name", 
	alb.title as "Album Title"
from artist as art
right join album as alb
	on art.artistid = alb.artistid;

--7.4 Create a cross join that joins album and artist and sorts by artist name in ascending order
select * from artist
cross join album
	order by artist.name asc;

--7.5 Perform a self-join on the employee table, joining on the reportsto column
select 
	concat(e.lastname, ', ', e.firstname) as "Employee Name",
	e.reportsto as "Reports To",
	concat(m.lastname, ', ', m.firstname) as "Manager"
from employee as e
inner join employee as m 
	on e.reportsto = m.employeeid
		order by m.employeeid asc;
