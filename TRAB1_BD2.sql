/* =========== Banco de dados ========== */
create table departamento(
	cod int primary key,
	nome varchar(30)
);

create table categoria(
	cod int primary key,
	nome varchar(30),
	dep int references departamento /*foreing key*/
);

create table produto(
	cod_prod int primary key,
	nome varchar(30),
	valor preco, --Dominio
	descricao varchar(200),
	cod_cat int references categoria
);

--Tem que alterar
create table register(
	operacao varchar(20),
	data date,
	id int
);
/* ===================================== */

/* ============== Tirgget ============== */
CREATE FUNCTION func_log() RETURNS trigger AS $BODY$
BEGIN
	-- O codigo tem que ter um if pois é necessario a clasula NEW para especificar que é algo novo
	IF (TG_OP = 'INSERT') THEN
		INSERT INTO register (operacao, data, id) VALUES (TG_OP, now(), NEW.cod_prod);
		RETURN NEW;
	END IF;
	INSERT INTO register (operacao, data, id) VALUES (TG_OP, now(), OLD.cod_prod);
	RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER triHistorico
AFTER INSERT OR UPDATE OR DELETE ON produto
FOR EACH ROW EXECUTE PROCEDURE func_log();
/* ===================================== */
/* ============= Domain ================ */
create domain preco AS DECIMAL(10, 2) check (value > 0);
/* ===================================== */

/* Insere dentro do banco de dados as hierarquias */
begin;
	insert into departamento values (1, 'casa e varejo'), (2, 'roupas e banho');
	insert into categoria values (1, 'eletronicos', 1), (2, 'moveis', 1);
	insert into categoria values (3, 'roupas femininas', 2), (4, 'roupoes e toalhas', 2);
commit;

/* Teste de inseção e consulta com commit */
begin work;
	insert into produto values (1, 'smartphone', 899.99, 'Smartphone com uma tela de 8 polegadas ...',  1);
commit work;
begin work;
	select * from produto; /*Mostra tudo dentro de produtos*/ 
commit work;
/* Mostra um produto cadastrado, pois a transação foi realizada com sucesso */
select * from produto;
select * from register;
/* ====================================== */

/* ==== Teste de inseção com rollback === */
begin; 
	insert into produto values (2, 'Cadeira de escritorio', 430, 'Altura do chão regulavel, trava do encosto...', 2);
rollback;
begin work;
	select * from produto; /*Mostra tudo dentro de produtos*/ 
commit work;
/* Mostra apenas um produto cadastrado, pois a transação nao foi realizada */
select * from produto;
/* ====================================== */

/* ===== Tratamento de concorrencia ===== */
begin;
	lock produto; --Consegue visualizar
	--Transação intermediaria
	begin;
		select * from produto;
	commit;
	update produto set valor = 700 where cod_prod = 1;
commit;
/* ====================================== */

/* ======= comandos de drop tables ====== */
drop function func_log() cascade;
drop table produto;
drop table categoria;
drop table departamento;
drop table register;
/* ====================================== */


--------------------Usuarios Banco de Dados--------------
CREATE USER paulo2 WITH PASSWORD 'paulo';
CREATE USER andre WITH PASSWORD 'andre';
CREATE USER joao WITH PASSWORD '1234';
GRANT UPDATE, DELETE, SELECT on produto to paulo2;
CREATE USER valdir WITH SUPERUSER ENCRYPTED PASSWORD '12345'; 
CREATE ROLE admin1 WITH SUPERUSER ENCRYPTED PASSWORD '12345'; 

-------------------------------------------------------------

------------Testes Banco de Dados-----------------------------
insert into departamento values (1, 'Financeiro');
insert into categoria values (1,'Contas', 1); 
select * from categoria;
delete from categoria where nome='MArcos'
---------------------------------------------------------------

--backup manual cmd
/*
1. Loga como postgres
2. psql -l para mostrar os bancos
3. pg_dump nome_db -f caminho/pra/salvar.sql
4. Apaga o banco antigo manualmente ou dropdb
5. Cria o banco novamente
6. pgdump nome_db < caminho/pro/backup.bkp
*/

/*
CREATE ROLE clientes;
CREATE ROLE gerentes;

CREATE ROLE galvao LOGIN PASSWORD '123' IN ROLE clientes;
CREATE ROLE mikeias LOGIN PASSWORD '123' IN ROLE gerentes;
*/
