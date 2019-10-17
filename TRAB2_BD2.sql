create domain preco as decimal(10,2) check (value > 0);

create type armazem as(
	cod int,
	produtos produto[]	--lista e associação
);

create type produto as (
	cod_prod int,
	nome varchar(30),
	valor preco, --Dominio
	descricao varchar(200)
);


create table estoque of armazem(
	cod primary key
);

create table produtos of produto(
	cod_prod primary key
);

insert into produtos values (1, 'mouse', 19.99, 'Mouse otico');
insert into estoque values (1, estoque.produtos(1, 'mouse', 19.99, 'Mouse otico'));

select * from estoque
select * from produtos;