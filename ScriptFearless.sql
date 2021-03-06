USE [master]
GO
/****** Object:  Database [Fearless_Style]    Script Date: 02/04/2019 10:30:44 ******/
CREATE DATABASE [Fearless_Style]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'RestauranteInterFood', FILENAME = N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\RestauranteInterFood.mdf' , SIZE = 4160KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'RestauranteInterFood_log', FILENAME = N'C:\Program Files (x86)\Microsoft SQL Server\MSSQL11.SQL2012\MSSQL\DATA\RestauranteInterFood_log.ldf' , SIZE = 1040KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [Fearless_Style] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Fearless_Style].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Fearless_Style] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Fearless_Style] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Fearless_Style] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Fearless_Style] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Fearless_Style] SET ARITHABORT OFF 
GO
ALTER DATABASE [Fearless_Style] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [Fearless_Style] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [Fearless_Style] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Fearless_Style] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Fearless_Style] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Fearless_Style] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Fearless_Style] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Fearless_Style] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Fearless_Style] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Fearless_Style] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Fearless_Style] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Fearless_Style] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Fearless_Style] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Fearless_Style] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Fearless_Style] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Fearless_Style] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Fearless_Style] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Fearless_Style] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Fearless_Style] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [Fearless_Style] SET  MULTI_USER 
GO
ALTER DATABASE [Fearless_Style] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Fearless_Style] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Fearless_Style] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Fearless_Style] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [Fearless_Style]
GO
/****** Object:  User [Fearless]    Script Date: 02/04/2019 10:30:44 ******/
CREATE USER [Fearless] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [Fearless]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [Fearless]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [Fearless]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [Fearless]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [Fearless]
GO
ALTER ROLE [db_datareader] ADD MEMBER [Fearless]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [Fearless]
GO
ALTER ROLE [db_denydatareader] ADD MEMBER [Fearless]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [Fearless]
GO
/****** Object:  StoredProcedure [dbo].[SpAsignarPromocion]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SpAsignarPromocion]
@Id_producto numeric(5,0),
@Id_promocion numeric(5, 0),
@Id_talla numeric(5, 0)
as 

update producto set bdPromocion_IdPromocion = @Id_promocion where IdProducto = @Id_producto and bdTalla_IdTalla = @Id_talla


GO
/****** Object:  StoredProcedure [dbo].[SpCambiarEstadoPedido]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[SpCambiarEstadoPedido](
 @idPedido int,
 @estado varchar (15))
 AS
 BEGIN
 UPDATE movimiento SET estado = @estado WHERE idMovimiento = @idPedido;
 END;
GO
/****** Object:  StoredProcedure [dbo].[SpCambiarPregunta]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SpCambiarPregunta](
@idPregunta int , 
@respuesta varchar(50),
@identificacion int) AS
	
	-- Cambiar pregunta
	UPDATE usuarios SET 
	pregunta_IdPregunta = @idPregunta, respuesta = @respuesta 
	WHERE identificacion = @identificacion;
GO
/****** Object:  StoredProcedure [dbo].[SpConsultaFormulasPedido]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- PROCEDIMIENTO CALCULAR PEDIDO PARA LA FACTURA
CREATE PROCEDURE [dbo].[SpConsultaFormulasPedido](
@idPedido int
)
AS
BEGIN
 SELECT SUM(pr.precio * deta.cantidadProducto) * (SELECT valor FROM configuracion WHERE idConfiguracion = 2)/100 as "iva", SUM(pr.precio * deta.cantidadProducto) *  ((SELECT valor FROM configuracion WHERE idConfiguracion = 1)/100) as "Propina",
 SUM(pr.precio * deta.cantidadProducto)  as "precioNeto", ((SUM(pr.precio * deta.cantidadProducto)) + (SUM(pr.precio * deta.cantidadProducto) * (SELECT valor FROM configuracion WHERE idConfiguracion = 2)/100) + (SUM(pr.precio * deta.cantidadProducto) * (SELECT valor FROM configuracion WHERE idConfiguracion = 1)/100)) as "PrecioTotal"
FROM detalleProducto_Pedido deta INNER JOIN producto pr ON deta.idProducto = pr.idProducto
 WHERE idPedido =@idPedido;
 END;

GO
/****** Object:  StoredProcedure [dbo].[SpConsultarColumnas]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 -- PROCEDIMIENTO QUE CONSULATA LA INFORMACIÓN DE LAS COLUMNAS DE UNA TABLA 
CREATE PROCEDURE [dbo].[SpConsultarColumnas](@nombreTabla VARCHAR(MAX))
AS
BEGIN
	
	SELECT TABLE_NAME "nombreTabla", COLUMN_NAME "nombreColumna", IS_NULLABLE "esNull", DATA_TYPE "tipo", CHARACTER_MAXIMUM_LENGTH "maxLength"
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE TABLE_NAME = @nombreTabla;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpConsultarFactura]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--PROCEDIMIENTO PARA LISTAR LA FACTURA
CREATE PROCEDURE [dbo].[SpConsultarFactura](
@idPedido int
)
AS 
BEGIN
SELECT ('000768'+cast(fac.idFactura as varchar) ) 'idFactura',fac.iva,fac.propina,fac.pagoNeto,fac.pagoBruto,pro.descripcionProducto,deta.cantidadProducto,pro.precio,   deta.cantidadProducto*pro.precio 'SubTotal',tpro.descripcionTipoProducto,   ('4F3JC0'+cast(ped.idPedido as varchar)) 'idPedido',cli.cedula as "Cedula_Cliente", cli.nombre+' '+ cli.apellido as "Nombre Cliente",ped.fecha,mes.cedula as "Cedula_Empleado",mes.nombre+' '+  mes.apellido as "Nombre Empleado"
  FROM pedido ped 
INNER JOIN usuario mes ON ped.idMesero = mes.idUsuario
INNER JOIN usuario cli ON ped.idCliente = cli.idUsuario
INNER JOIN detalleProducto_Pedido deta ON ped.idPedido = deta.idPedido
INNER JOIN producto pro ON deta.idProducto = pro.idProducto
INNER JOIN tipoProducto tpro ON pro.idTipoProducto=tpro.idTipoProducto
INNER JOIN factura fac ON ped.idPedido = fac.idPedido
WHERE ped.idPedido = @idPedido;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpConsultarProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpConsultarProducto](
@referencia int,
@talla int
)
AS
 SELECT * from producto
 WHERE referencia = @referencia and bdTalla_IdTalla = @talla;
GO
/****** Object:  StoredProcedure [dbo].[SpConsultarProductosPedido]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpConsultarProductosPedido] (
@id int,
@identificacion int)
As
SELECT ped.idMovimiento as "ID", ped.fecha_movimiento as "Fecha", ped.usuarios_identificacion as "Cedula", u.nombres + ' ' + u.apellidos as "Nombre Cliente", ped.numeroComunicacion as "Telefono", d.bdProducto_IdProducto as "Producto", d.cantidad as "Cantidad", d.descuento as "Descuento", d.precio as "Precio", p.imagen1 as "Imagen1"
FROM movimiento ped INNER JOIN detalleMovimiento d ON ped.idMovimiento = d.Movimiento_idMovimiento
INNER JOIN usuarios u ON ped.usuarios_identificacion = u.identificacion
INNER JOIN producto p ON d.bdProducto_IdProducto = p.IdProducto
WHERE ped.idMovimiento = @id and ped.usuarios_identificacion = @identificacion

GO
/****** Object:  StoredProcedure [dbo].[SpEliminarProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- PROCEDIMIENTO ELIMINAR PRODUCTO
CREATE PROCEDURE [dbo].[SpEliminarProducto](@idProducto INT) AS
BEGIN

	DELETE FROM producto WHERE idProducto = @idProducto; 

END;

GO
/****** Object:  StoredProcedure [dbo].[SpGenerarFacturaAntigua]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[SpGenerarFacturaAntigua]
 AS
 BEGIN
 SELECT  fac.idFactura,  ped.idPedido,mes.cedula as "Cedula Mesero",mes.nombre +' '+ mes.apellido as "Nombre Empleado",fecha,cli.nombre+' '+cli.apellido 'Nombre Cliente',cli.apellido 'Apellido Cliente',cli.cedula as "Cedula Cliente",en.descripcionEnser
 FROM pedido ped INNER JOIN enser en ON ped.idEnser = en.idEnser
INNER JOIN usuario mes ON ped.idMesero = mes.idUsuario INNER JOIN usuario cli ON ped.idCliente=cli.idUsuario
INNER JOIN factura fac ON ped.idPedido = fac.idPedido
 WHERE LOWER(ped.estado) = 'facturado'
 ORDER BY fecha DESC;
 END;

GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarClasificacion]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpHabilitarClasificacion]
(@idClasificacion INT) AS
BEGIN
	UPDATE clasificacionProducto SET 
	estado = 'Activo'
	WHERE idClasificacionProducto = @idClasificacion;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarDiseno]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpHabilitarDiseno]
(@idDiseno INT) AS
	UPDATE diseno SET 
	estado = 'Activo'
	WHERE idDiseno = @idDiseno;
GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarMotivoAgenda]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		create PROCEDURE [dbo].[SpHabilitarMotivoAgenda]
(@idMotivo INT) AS
	UPDATE motivoAgenda SET 
	estado = 'Activo'
	WHERE idMotivoAgenda = @idMotivo;
GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarMotivoCambio]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create PROCEDURE [dbo].[SpHabilitarMotivoCambio]
(@idMotivoCambio INT) AS
	UPDATE motivoCambio SET 
	estado = 'Activo'
	WHERE idMotivoCambio = @idMotivoCambio;
GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarPregunta]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpHabilitarPregunta]
(@idPregunta INT) AS
	UPDATE pregunta SET 
	estado = 'Activo'
	WHERE idPregunta = @idPregunta;
GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarSubTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[SpHabilitarSubTipoProducto](
@idSubTipoProducto INT) AS
	UPDATE subTipoProducto SET 
	estado = 'Activo'
	WHERE idSubTipo = @idSubTipoProducto;
GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarTalla]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpHabilitarTalla]
(@IdTalla INT) AS
BEGIN
	UPDATE talla SET 
	estado = 'Activo'
	WHERE idTalla = @IdTalla;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- PROCEDIMIENTO HABILITAR TIPO PRODUCTO
CREATE PROCEDURE [dbo].[SpHabilitarTipoProducto](@idTipoProducto INT) AS
BEGIN

	UPDATE tipoProducto SET 
	estado = 'Activo'
	WHERE idTipoProducto = @idTipoProducto;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpHabilitarTipoUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDIMIENTO HABILITAR TIPO USUARIO
CREATE PROCEDURE [dbo].[SpHabilitarTipoUsuario](@id INT) AS
BEGIN

	UPDATE tipoUsuario SET 
	estado = 'Activo'
	WHERE idTipoUsuario = @id;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarClasificacion]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpInhabilitarClasificacion]
(@idClasificacion INT) AS
BEGIN
	UPDATE clasificacionProducto SET 
	estado = 'Inactivo'
	WHERE idClasificacionProducto = @idClasificacion;

END;
GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarDiseno]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpInhabilitarDiseno]
(@idDiseno INT) AS
	UPDATE diseno SET 
	estado = 'Inactivo'
	WHERE idDiseno = @idDiseno;
GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarMotivoAgenda]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		create PROCEDURE [dbo].[SpInhabilitarMotivoAgenda]
(@idMotivo INT) AS
	UPDATE motivoAgenda SET 
	estado = 'Inactivo'
	WHERE idMotivoAgenda = @idMotivo;
GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarMotivoCambio]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create PROCEDURE [dbo].[SpInhabilitarMotivoCambio]
(@idMotivoCambio INT) AS
	UPDATE motivoCambio SET 
	estado = 'Inactivo'
	WHERE idMotivoCambio = @idMotivoCambio;
GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarPregunta]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpInhabilitarPregunta]
(@idPregunta INT) AS
	UPDATE pregunta SET 
	estado = 'Inactivo'
	WHERE idPregunta = @idPregunta;
GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarSubTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[SpInhabilitarSubTipoProducto](
@idSubTipoProducto INT) AS
	UPDATE subTipoProducto SET 
	estado = 'Inactivo'
	WHERE idSubTipo = @idSubTipoProducto;
GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarTalla]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpInhabilitarTalla](@idTalla INT) AS
BEGIN

	UPDATE talla SET 
	estado = 'Inactivo'
	WHERE idTalla = @idTalla;

END;
GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDIMIENTO INHABILITAR TIPO PRODUCTO
CREATE PROCEDURE [dbo].[SpInhabilitarTipoProducto](@idTipoProducto INT) AS
BEGIN

	UPDATE tipoProducto SET 
	estado = 'Inactivo'
	WHERE idTipoProducto = @idTipoProducto;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpInhabilitarTipoUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDIMIENTO INHABILITAR TIPO USUARIO
CREATE PROCEDURE [dbo].[SpInhabilitarTipoUsuario](@id INT) AS
BEGIN

	UPDATE tipoUsuario SET 
	estado = 'Inactivo'
	WHERE idTipoUsuario = @id;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpListarCiudades]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpListarCiudades] AS
BEGIN
	-- Consultar todos los productos 
	SELECT * frOM ciudades

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarClasificaciones]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarClasificaciones] AS
BEGIN
	
	-- Consultar todos los tipos productos 
	SELECT * FROM clasificacionProducto
	where estado = 'Activo'

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarDepartamentos]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpListarDepartamentos] AS
BEGIN
	-- Consultar todos los productos 
	SELECT * frOM departamentos

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarDisenos]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SpListarDisenos]
as
select * from diseno;
GO
/****** Object:  StoredProcedure [dbo].[SpListarFiltroClasificaciones]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarFiltroClasificaciones] (
 @id int) AS

BEGIN
	select * from clasificacionProducto
where estado = 'Activo' and tipoProducto_idTipoProducto = @id
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarMotivoAgenda]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SpListarMotivoAgenda]
as
select * from motivoAgenda;
GO
/****** Object:  StoredProcedure [dbo].[SpListarMotivoCambio]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SpListarMotivoCambio]
as
select * from motivoCambio;
GO
/****** Object:  StoredProcedure [dbo].[SpListarMovimiento]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarMovimiento] AS
BEGIN
	-- Consultar todos los movimientos 
	SELECT M.idMovimiento, M.usuarios_identificacion, M.direccion, M.numeroComunicacion, M.descripcion, M.fecha_movimiento, TP.descripcioMovimiento, M.estado, M.subtotal, M.descuento, M.iva, M.total
	FROM movimiento M INNER JOIN tipoMovimiento TP ON (M.tipoMovimiento_idTipo_movimiento = TP.idTipo_movimiento )

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarPedidos]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarPedidos]
As
BEGIN
SELECT ped.idMovimiento as "ID", ped.fecha_movimiento as "Fecha", ped.usuarios_identificacion as "Cedula", usu.nombres + ' ' + usu.apellidos as "Nombre Cliente", ped.direccion as "Direccion", ped.numeroComunicacion as "Telefono", ped.descripcion as "Descripcion", ped.descuento as "Descuentos", ped.total as "Total", ped.estado as "Estado"
FROM movimiento ped INNER JOIN usuarios usu ON ped.usuarios_identificacion = usu.identificacion
WHERE LOWER(ped.estado) = 'PENDIENTE'
ORDER BY fecha_movimiento DESC;
END;

GO
/****** Object:  StoredProcedure [dbo].[SpListarPedidosCancelado]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarPedidosCancelado]
As
BEGIN
SELECT ped.idMovimiento as "ID", ped.fecha_movimiento as "Fecha", ped.usuarios_identificacion as "Cedula", usu.nombres + ' ' + usu.apellidos as "Nombre Cliente", ped.direccion as "Direccion", ped.numeroComunicacion as "Telefono", ped.descripcion as "Descripcion", ped.descuento as "Descuentos", ped.total as "Total", ped.estado as "Estado"
FROM movimiento ped INNER JOIN usuarios usu ON ped.usuarios_identificacion = usu.identificacion
WHERE LOWER(ped.estado) = 'CANCELADO'
ORDER BY fecha_movimiento DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarPedidosCliente]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpListarPedidosCliente] (
@id int) AS
	-- Consultar todos los pedidos del cliente
	SELECT * 
	from movimiento 
	where usuarios_identificacion = @id
GO
/****** Object:  StoredProcedure [dbo].[SpListarPedidosEnProceso]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarPedidosEnProceso]
As
BEGIN
SELECT ped.idMovimiento as "ID", ped.fecha_movimiento as "Fecha", ped.usuarios_identificacion as "Cedula", usu.nombres + ' ' + usu.apellidos as "Nombre Cliente", ped.direccion as "Direccion", ped.numeroComunicacion as "Telefono", ped.descripcion as "Descripcion", ped.descuento as "Descuentos", ped.total as "Total", ped.estado as "Estado"
FROM movimiento ped INNER JOIN usuarios usu ON ped.usuarios_identificacion = usu.identificacion
WHERE LOWER(ped.estado) = 'PROCESO'
ORDER BY fecha_movimiento DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarPedidosFinalizado]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarPedidosFinalizado]
As
BEGIN
SELECT ped.idMovimiento as "ID", ped.fecha_movimiento as "Fecha", ped.usuarios_identificacion as "Cedula", usu.nombres + ' ' + usu.apellidos as "Nombre Cliente", ped.direccion as "Direccion", ped.numeroComunicacion as "Telefono", ped.descripcion as "Descripcion", ped.descuento as "Descuentos", ped.total as "Total", ped.estado as "Estado"
FROM movimiento ped INNER JOIN usuarios usu ON ped.usuarios_identificacion = usu.identificacion
WHERE LOWER(ped.estado) = 'FINALIZADO'
ORDER BY fecha_movimiento DESC;
END;

GO
/****** Object:  StoredProcedure [dbo].[SpListarPreguntas]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SpListarPreguntas]
as
select * from pregunta;
GO
/****** Object:  StoredProcedure [dbo].[SpListarProductos]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarProductos] AS
BEGIN
	
	-- Consultar todos los productos 
	SELECT P.IdProducto , P.referencia , P.nombreProducto, P.descripcionProducto , P.inventario , P.estadoProducto , P.precioCompra, P.edicionLimitada, P.precio, P.bdPromocion_IdPromocion, P.bdClasificacionProducto_IdClasificacionProducto, P.bdTalla_IdTalla, promo.efectivo, promo.porcentaje, p.imagen1, p.imagen2, p.imagen3, p.imagen4, p.imagen5
	FROM producto P inner join promocion promo on P.bdPromocion_IdPromocion = promo.idPromocion
	WHERE P.inventario > 0; 
	
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarProductosPedido]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarProductosPedido](
@idpedido int)
As
BEGIN
select p.referencia, p.nombreProducto, p.edicionLimitada, cantidad, t.nombreTalla
from detalleMovimiento dm inner join producto p on p.IdProducto = dm.bdProducto_IdProducto 
inner join talla t on t.idTalla = p.bdTalla_IdTalla
where Movimiento_idMovimiento = @idpedido
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarPromociones]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarPromociones] AS
BEGIN
	
	-- Consultar todos los tipos productos 
	SELECT * FROM promocion where estado = 'Activo'; 

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarReferencia]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SpListarReferencia] 
as

select referencia as 'idReferencia', CONVERT(VARCHAR(50),referencia) + ' - ' + nombreProducto as 'referencia'
from producto 
group by referencia, nombreProducto

GO
/****** Object:  StoredProcedure [dbo].[SpListarSubtiposProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SpListarSubtiposProducto]
as 
SELECT * FROM subTipoProducto; 
GO
/****** Object:  StoredProcedure [dbo].[SpListarTallas]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarTallas](@estado VARCHAR (45)) AS
BEGIN
	
	SELECT * FROM talla WHERE estado = @estado;
	
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTallasReferencia]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SpListarTallasReferencia] (@referencia int ) 
as
select P.IdProducto as 'idProducto' , T.nombreTalla as 'Talla'
from producto P INNER JOIN talla T ON (P.bdTalla_IdTalla = T.idTalla)
where referencia = @referencia and P.inventario > 0
GO
/****** Object:  StoredProcedure [dbo].[SpListarTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpListarTipoProducto] AS
BEGIN
	
	-- Consultar todos los tipos productos 
	SELECT * FROM tipoProducto
	where estado = 'Activo'

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTiposMovimiento]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[SpListarTiposMovimiento] AS
BEGIN
	-- Consultar todos los movimientos 
	SELECT * frOM tipoMovimiento

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTiposProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- PROCEDIMIENTO LISTAR TODOS LOS TIPOS DE PRODUCTOS
CREATE PROCEDURE [dbo].[SpListarTiposProducto] AS
BEGIN
	
	-- Consultar todos los tipos productos 
	SELECT * FROM tipoProducto
	where estado = 'Activo'
END;

GO
/****** Object:  StoredProcedure [dbo].[SpListarTiposProducto1]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpListarTiposProducto1] AS
BEGIN
	
	-- Consultar todos los tipos productos 
	SELECT * FROM tipoProducto

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTiposUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDIMIENTO LISTAR TODOS LOS TIPOS DE USUARIO
CREATE PROCEDURE [dbo].[SpListarTiposUsuario] AS
BEGIN
	
	-- Consultar todos los tipos usuario 
	SELECT * FROM tipoUsuario; 

END;

GO
/****** Object:  StoredProcedure [dbo].[SpListarTiposUsuarios]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarTiposUsuarios] AS
BEGIN
	-- Consultar todos los productos 
	SELECT * frOM tipoUsuario

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTodasClasificaciones]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[SpListarTodasClasificaciones] AS
BEGIN

	SELECT * FROM clasificacionProducto;

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTodasTallas]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarTodasTallas] AS
BEGIN

	SELECT * FROM talla;

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTodosPedidos]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarTodosPedidos] AS
BEGIN
	
	-- Consultar todos los productos 
	SELECT idMovimiento, usuarios_identificacion, direccion, numeroComunicacion, descripcion, s.nombres + ' ' + s.apellidos AS 'NombreCompleto' 
	FROM movimiento m inner join usuarios s on s.identificacion = m.usuarios_identificacion

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTodosProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarTodosProducto] AS
BEGIN
	
	-- Consultar todos los productos 
	select IdProducto, referencia, nombreProducto, descripcionProducto, inventario, stockMinimo, estadoProducto, precioCompra, edicionLimitada, precio, bdPromocion_IdPromocion, bdClasificacionProducto_IdClasificacionProducto, bdTalla_IdTalla, imagen1, imagen2, imagen3, imagen4, imagen5, promocion.nombrePromocion, clasificacionProducto.nombreClasificacion, talla.nombreTalla, diseno
	from producto inner join promocion on producto.bdPromocion_IdPromocion = promocion.idPromocion 
	inner join clasificacionProducto on producto.bdClasificacionProducto_IdClasificacionProducto = clasificacionProducto.idClasificacionProducto
	inner join talla on producto.bdTalla_IdTalla = talla.idTalla
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTodosProductoFiltro]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarTodosProductoFiltro] (
 @id int) AS

BEGIN
	
	-- Consultar todos los productos por ref
	SELECT referencia, nombreProducto, descripcionProducto, precio, imagen1
	from producto P inner join clasificacionProducto C on P.bdClasificacionProducto_IdClasificacionProducto = C.idClasificacionProducto
	where C.tipoProducto_idTipoProducto = @id
	group by referencia, nombreProducto, descripcionProducto, precio, imagen1
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTodosProductoFiltro1]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpListarTodosProductoFiltro1] (
 @id int) AS

BEGIN
	
	-- Consultar todos los productos por ref
	SELECT referencia, nombreProducto, descripcionProducto, precio, imagen1
	from producto P inner join clasificacionProducto C on P.bdClasificacionProducto_IdClasificacionProducto = C.idClasificacionProducto
	where C.idClasificacionProducto = @id
	group by referencia, nombreProducto, descripcionProducto, precio, imagen1
END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTodosProductoRef]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarTodosProductoRef] AS
BEGIN
	
	-- Consultar todos los productos por ref
	SELECT referencia, nombreProducto, descripcionProducto, precio, imagen1
	from producto
	group by referencia, nombreProducto, descripcionProducto, precio, imagen1

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarTodosPromociones]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpListarTodosPromociones] AS
BEGIN
	
	-- Consultar todos las promociones 
	SELECT * FROM promocion

END;
GO
/****** Object:  StoredProcedure [dbo].[SpListarUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpListarUsuario] AS
BEGIN
	
select * from usuarios


END;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarClasificacion]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpModificarClasificacion]
(@nombre VARCHAR(45), 
@idTipoProducto int,
@idSubtipo int,
@idClasificacion INT) AS
BEGIN
	
	-- Modificar clasificacion
	UPDATE clasificacionProducto set 
	nombreClasificacion = @nombre, 
	tipoProducto_idTipoProducto = @idTipoProducto,
	subTiposProducto_idSubTipo = @idSubtipo
	WHERE idClasificacionProducto = @idClasificacion;
END;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarDiseno]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	create procedure [dbo].[SpModificarDiseno](
@nombreDiseno VARCHAR(30) , 
@idDiseno INT) AS
	
	-- Modificar subtipo producto
	UPDATE diseno SET 
	nombreDiseno = @nombreDiseno 
	WHERE idDiseno = @idDiseno;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarImagenes]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpModificarImagenes](
@fileName varchar(1000),
@id int) AS
BEGIN
	
	-- Modificar Producto
	UPDATE producto SET imagen1 = @fileName where referencia = @id

END;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarMotivoAgenda]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
			create procedure [dbo].[SpModificarMotivoAgenda](
@motivo VARCHAR(45) , 
@idCambio INT) AS
	
	-- Modificar subtipo producto
	UPDATE motivoAgenda SET 
	motivoAgendas = @motivo 
	WHERE idMotivoAgenda = @idCambio;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarMotivoCambio]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
		create procedure [dbo].[SpModificarMotivoCambio](
@motivo VARCHAR(45) , 
@idCambio INT) AS
	
	-- Modificar subtipo producto
	UPDATE motivoCambio SET 
	motivoCambios = @motivo 
	WHERE idMotivoCambio = @idCambio;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarPregunta]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	create procedure [dbo].[SpModificarPregunta](
@nombrePregunta VARCHAR(45) , 
@idPregunta INT) AS
	
	-- Modificar subtipo producto
	UPDATE pregunta SET 
	nombrePregunta = @nombrePregunta 
	WHERE idPregunta = @idPregunta;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpModificarProducto](
@nombreProducto varchar(25),
@descripcionProducto varchar(45),
@inventario float,
@stockMinimo float,
@estadoProducto varchar(10),
@precioCompra float,
@edicionLimitada varchar(2),
@precio float,
@promo int,
@clasificacion int,
@talla int,
@diseno int,
@idProducto int) AS
BEGIN
	
	-- Modificar Producto
	UPDATE producto SET 
	nombreProducto = @nombreProducto,
	descripcionProducto = @descripcionProducto ,
	inventario = @inventario ,
	stockMinimo = @stockMinimo ,
	estadoProducto = @estadoProducto ,
	precioCompra = @precioCompra,
	edicionLimitada = @edicionLimitada,
	precio = @precio,
	bdPromocion_IdPromocion = @promo,
	bdClasificacionProducto_IdClasificacionProducto = @clasificacion,
	bdTalla_IdTalla = @talla,
	diseno = @diseno
	WHERE idProducto = @idProducto;
END;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarPromocion]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpModificarPromocion](
@nombrePromocion varchar(45),
@descripcion varchar(100),
@porcentaje float,
@efectivo float,
@vigencia date,
@estado varchar(10),
@idPromocion int) AS
BEGIN
	-- Modificar promocion
	UPDATE promocion SET 
	nombrePromocion = @nombrePromocion ,
	descripcion = @descripcion ,
	porcentaje = @porcentaje ,
	efectivo = @efectivo ,
	vigencia = @vigencia,
	estado = @estado
	WHERE idPromocion = @idPromocion;
END;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarSubTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[SpModificarSubTipoProducto](
@clasificacion VARCHAR(45) , 
@idTipoProducto INT) AS
	
	-- Modificar subtipo producto
	UPDATE subTipoProducto SET 
	clasificacion = @clasificacion 
	WHERE idSubTipo = @idTipoProducto;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarTalla]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpModificarTalla]


(@talla VARCHAR(45), @IdTalla INT) AS
BEGIN
	
	-- Modificar zona
	UPDATE talla SET 
	nombreTalla = @talla
	WHERE idTalla = @IdTalla;
END;
GO
/****** Object:  StoredProcedure [dbo].[SpModificarTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDIMIENTO MODIFICAR TIPO PRODUCTO
CREATE PROCEDURE [dbo].[SpModificarTipoProducto](@descripcion VARCHAR(45) , @idTipoProducto INT) AS
BEGIN
	
	-- Modificar tipo producto
	UPDATE tipoProducto SET 
	descripcionTipoProducto = @descripcion 
	WHERE idTipoProducto = @idTipoProducto;
END;

GO
/****** Object:  StoredProcedure [dbo].[SpModificarTipoUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDIMIENTO MODIFICAR TIPO USUARIO
CREATE PROCEDURE [dbo].[SpModificarTipoUsuario](@descripcion VARCHAR(45) , @id INT) AS
BEGIN
	
	-- Modificar tipo usuario
	UPDATE tipoUsuario SET 
	descripcionTipoUsuario = @descripcion 
	WHERE idTipoUsuario = @id;
END;

GO
/****** Object:  StoredProcedure [dbo].[SpModificarUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpModificarUsuario](
@nombres VARCHAR(40), 
@apellidos VARCHAR(40),
@idDepartamento int, 
@idCiudad INT,
@direccionResidencia varchar(50),
@email varchar(40),
@estadoCuenta varchar(12),
@fechaNacimiento dateTime,
@password varchar(30),
@respuesta varchar(30),
@idTipoUsuario int,
@idPregunta int,
@identificacion int) AS

	-- Registrar Usuario
	update usuarios set nombres = @nombres, apellidos = @apellidos, idDepartamento = @idDepartamento,
	idCiudad = @idCiudad, direccionResidencia = @direccionResidencia, email = @email, estadoCuenta = @estadoCuenta,
	fechaNacimiento = @fechaNacimiento, password = @password, respuesta = @respuesta, tipoUsuario_IdTipo = @idTipoUsuario,
	pregunta_IdPregunta = @idPregunta 
	where identificacion = @identificacion
GO
/****** Object:  StoredProcedure [dbo].[SpModificarUsuarioCliente]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create pROCEDURE [dbo].[SpModificarUsuarioCliente](
@nombres VARCHAR(40), 
@apellidos VARCHAR(40),
@idDepartamento int, 
@idCiudad INT,
@direccionResidencia varchar(50),
@email varchar(40),
@fechaNacimiento dateTime,
@identificacion int) AS

	-- modificar Usuario
	update usuarios set nombres = @nombres, apellidos = @apellidos, idDepartamento = @idDepartamento,
	idCiudad = @idCiudad, direccionResidencia = @direccionResidencia, email = @email,
	fechaNacimiento = @fechaNacimiento 
	where identificacion = @identificacion
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarClasificacion]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpRegistrarClasificacion]
(@nombre VARCHAR(25),
@tipoProducto int, 
@subtipos int) AS
BEGIN
	
	-- Registrar zona
	INSERT INTO clasificacionProducto VALUES(@nombre, @tipoProducto, @subtipos, 'Activo');
END;
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarDetalleProductoPedido]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpRegistrarDetalleProductoPedido]
(@idPedido INT ,
 @idProducto INT , 
 @cantidad float,
 @precio float,
 @descuento float) AS
BEGIN
	
	-- Registrar detalleProducto_Pedido
	INSERT INTO detalleMovimiento VALUES(@idPedido , @idProducto , @cantidad, @precio, @descuento);

	-- Actualizar la cantidad de productos disponibles
	UPDATE producto SET inventario -= @cantidad WHERE IdProducto = @idProducto;

END;
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarDetalleProductoPedido1]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpRegistrarDetalleProductoPedido1]
(@idPedido INT ,
 @idProducto INT , 
 @cantidad float,
 @precio float,
 @descuento float) AS
BEGIN
	
	-- Registrar detalleProducto_Pedido
	INSERT INTO detalleMovimiento VALUES(@idPedido , @idProducto , @cantidad, @precio, @descuento);

	-- Actualizar la cantidad de productos disponibles
	UPDATE producto SET inventario += @cantidad WHERE IdProducto = @idProducto;

END;
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarDiseno]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SpRegistrarDiseno]
@nombreDiseno varchar(30)
as 
insert into diseno values (@nombreDiseno, 'Activo');
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarFactura]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- PROCEDIMIENTO PARA REGISTRAR LA FACTURA
CREATE PROCEDURE [dbo].[SpRegistrarFactura](
@idPedido int,
@propina float,
@iva float,
@pagoBruto float,
@pagoNeto float
)
AS
BEGIN
INSERT INTO factura (idPedido,propina,iva,pagoBruto,pagoNeto)VALUES(@idPedido,@propina,@iva,@pagoBruto,@pagoNeto);
END;

GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarMotivoAgenda]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SpRegistrarMotivoAgenda]
@motivo varchar(45)
as 
insert into motivoAgenda values (@motivo, 'Activo');
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarMotivoCambio]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SpRegistrarMotivoCambio]
@motivo varchar(45)
as 
insert into motivoCambio values (@motivo, 'Activo');
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarMovimiento]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpRegistrarMovimiento](
@idUsuario int,
@direccion varchar(20),
@numeroComunicacion varchar(20),
@descripcion varchar(45),
@tipoMovimiento int,
@subtotal float,
@descuento float,
@total float) AS
BEGIN
	INSERT INTO movimiento VALUES(@idUsuario, @direccion, @numeroComunicacion, @descripcion, SYSDATETIME() , @tipoMovimiento , 'FINALIZADO', @subtotal, @descuento, 0, @total);
	SELECT IDENT_CURRENT( 'movimiento' ) AS idUltimoPedido;
END;
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarPedido]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpRegistrarPedido](
@idUsuario int,
@direccion varchar(20),
@numeroComunicacion varchar(20),
@descripcion varchar(45),
@subtotal float,
@descuento float,
@total float) AS
BEGIN
	INSERT INTO movimiento VALUES(@idUsuario, @direccion, @numeroComunicacion, @descripcion, SYSDATETIME() , 2 , 'PENDIENTE', @subtotal, @descuento, 0, @total);
	SELECT IDENT_CURRENT( 'movimiento' ) AS idUltimoPedido;
END;
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarPregunta]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[SpRegistrarPregunta]
@pregunta varchar(45)
as 
insert into pregunta values (@pregunta, 'Activo');
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpRegistrarProducto](
@referencia int,
@nombreProducto varchar(25),
@descripcionProducto VARCHAR(50),
@inventario float,
@stockMinimo FLOAT,
@estadoProducto varchar(10),
@precioCompra float,
@edicionLimitada varchar(2),
@precio float,
@promo int,
@clasificacion int,
@talla int,
@diseno int) AS
BEGIN
	
	-- Registrar Producto
	INSERT INTO producto VALUES(@referencia, @nombreProducto, @descripcionProducto, @inventario, @stockMinimo, @estadoProducto, @precioCompra, @edicionLimitada, @precio, @promo, @clasificacion, @talla, null, null, null, null, null, @diseno);
END;
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarPromocion]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpRegistrarPromocion](
@nombrePromocion varchar(50),
@descripcion varchar(100),
@porcentaje int,
@efectivo int,
@vigencia date,
@estado varchar(10))
AS
BEGIN
	INSERT INTO promocion VALUES(@nombrePromocion, @descripcion, @porcentaje, @efectivo, @vigencia, 'Activo');
END;
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarSubTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[SpRegistrarSubTipoProducto]
@clasificacion varchar(45)
as 
insert into subTipoProducto values (@clasificacion, 'Activo');
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarTalla]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpRegistrarTalla]

(@talla VARCHAR(8)) AS
BEGIN
	
	-- Registrar zona
	INSERT INTO talla VALUES(@talla, 'Activo');
END;
GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDIMIENTO REGISTRAR TIPO PRODUCTO
CREATE PROCEDURE [dbo].[SpRegistrarTipoProducto](
	@descripcionTipoProducto VARCHAR(45)
) AS
BEGIN
	
	-- Registrar tipo producto
	INSERT INTO tipoProducto VALUES(@descripcionTipoProducto , 'Activo');
END;

GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarTipoUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- PROCEDIMIENTO REGISTRAR TIPO USUARIO
CREATE PROCEDURE [dbo].[SpRegistrarTipoUsuario](
	@descripcion VARCHAR(45)
) AS
BEGIN
	
	-- Registrar tipo usuario
	INSERT INTO tipoUsuario VALUES(@descripcion , 'Activo');
END;

GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpRegistrarUsuario](
@identificacion int,
@nombres VARCHAR(40), 
@apellidos VARCHAR(40),
@idDepartamento int, 
@idCiudad INT,
@direccionResidencia varchar(50),
@email varchar(40),
@estadoCuenta varchar(12),
@fechaNacimiento dateTime,
@password varchar(30),
@respuesta varchar(30),
@idTipoUsuario int,
@idPregunta int) AS

	-- Registrar Usuario
	INSERT INTO usuarios VALUES(@identificacion, @nombres , @apellidos , @idDepartamento , @idCiudad, @direccionResidencia, @email, @estadoCuenta, @fechaNacimiento, @password, @respuesta, @idTipoUsuario, @idPregunta);

GO
/****** Object:  StoredProcedure [dbo].[SpRegistrarUsuario1]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpRegistrarUsuario1](
@identificacion int,
@nombres VARCHAR(40), 
@apellidos VARCHAR(40),
@email varchar(40),
@password varchar(30),
@idPregunta int,
@respuesta varchar(30)) AS
	-- Registrar Usuario


	INSERT INTO usuarios VALUES(@identificacion, @nombres, @apellidos, null, null, null, @email, 'Activo', null, @password, @respuesta, 2, 1);
GO
/****** Object:  StoredProcedure [dbo].[SpValidarCliente]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- VALIDADR CLIENTE
CREATE PROCEDURE [dbo].[SpValidarCliente]( @cedula int) AS
BEGIN
	-- Consultar al cliente por medio de su cedula
	SELECT * FROM usuarios WHERE identificacion = @cedula AND tipoUsuario_IdTipo = 2;

END;

GO
/****** Object:  StoredProcedure [dbo].[SpValidarProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SpValidarProducto]( @idProducto int) AS
BEGIN
	-- Consultar al cliente por medio de su cedula
	SELECT * FROM producto WHERE IdProducto = @idProducto AND estadoProducto = 'Disponible';

END;
GO
/****** Object:  StoredProcedure [dbo].[SpValidarUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpValidarUsuario]( @cedula VARCHAR(25) ) AS
BEGIN
	
	-- Consultar el usuario por medio de su cedula
	SELECT * FROM usuarios WHERE identificacion = @cedula;

END;
GO
/****** Object:  StoredProcedure [dbo].[SpValidarUsuarioLogin]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SpValidarUsuarioLogin](
@nombreUsuario Varchar(45),
@clave VARCHAR(45)
)
AS
BEGIN
	SELECT email, identificacion, descripcionTipoUsuario 
	FROM usuarios u INNER JOIN tipoUsuario tu ON u.tipoUsuario_IdTipo = tu.idTipoUsuario 
	WHERE email = @nombreUsuario AND password = @clave;
END;
GO
/****** Object:  Table [dbo].[ciudades]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ciudades](
	[idCiudad] [int] NOT NULL,
	[ciudad] [varchar](30) NOT NULL,
	[estado] [varchar](10) NOT NULL,
 CONSTRAINT [PK_ciudades] PRIMARY KEY CLUSTERED 
(
	[idCiudad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[clasificacionProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[clasificacionProducto](
	[idClasificacionProducto] [int] IDENTITY(1,1) NOT NULL,
	[nombreClasificacion] [varchar](40) NOT NULL,
	[tipoProducto_idTipoProducto] [int] NOT NULL,
	[subTiposProducto_idSubTipo] [int] NOT NULL,
	[estado] [varchar](10) NOT NULL,
 CONSTRAINT [PK__bdClasif__F123EEF96F93E4D9] PRIMARY KEY CLUSTERED 
(
	[idClasificacionProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[departamentos]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[departamentos](
	[idDepartamento] [int] IDENTITY(1,1) NOT NULL,
	[departamento] [varchar](26) NOT NULL,
	[estado] [nchar](10) NOT NULL,
 CONSTRAINT [PK_departamentos] PRIMARY KEY CLUSTERED 
(
	[idDepartamento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[detalleDiseno]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[detalleDiseno](
	[idDetalleDiseno] [int] IDENTITY(1,1) NOT NULL,
	[idDiseno] [int] NOT NULL,
	[idProducto] [int] NOT NULL,
 CONSTRAINT [PK_detalleDiseno] PRIMARY KEY CLUSTERED 
(
	[idDetalleDiseno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[detalleMovimiento]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[detalleMovimiento](
	[iddetalleMovimiento] [int] IDENTITY(1,1) NOT NULL,
	[Movimiento_idMovimiento] [int] NULL,
	[bdProducto_IdProducto] [int] NOT NULL,
	[cantidad] [float] NOT NULL,
	[precio] [float] NOT NULL,
	[descuento] [float] NOT NULL,
 CONSTRAINT [PK__detalleM__DEFD8D53975C9137] PRIMARY KEY CLUSTERED 
(
	[iddetalleMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[diseno]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[diseno](
	[idDiseno] [int] IDENTITY(1,1) NOT NULL,
	[nombreDiseno] [varchar](30) NOT NULL,
	[estado] [varchar](8) NOT NULL,
 CONSTRAINT [PK_diseno] PRIMARY KEY CLUSTERED 
(
	[idDiseno] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[motivoAgenda]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[motivoAgenda](
	[idMotivoAgenda] [int] IDENTITY(1,1) NOT NULL,
	[motivoAgendas] [varchar](45) NOT NULL,
	[estado] [varchar](10) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[motivoCambio]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[motivoCambio](
	[idMotivoCambio] [int] IDENTITY(1,1) NOT NULL,
	[motivoCambios] [varchar](45) NOT NULL,
	[estado] [varchar](10) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[movimiento]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[movimiento](
	[idMovimiento] [int] IDENTITY(1,1) NOT NULL,
	[usuarios_identificacion] [int] NOT NULL,
	[direccion] [varchar](20) NULL,
	[numeroComunicacion] [nchar](20) NULL,
	[descripcion] [varchar](45) NULL,
	[fecha_movimiento] [datetime2](7) NOT NULL,
	[tipoMovimiento_idTipo_movimiento] [int] NOT NULL,
	[estado] [varchar](10) NOT NULL,
	[subtotal] [float] NOT NULL,
	[descuento] [float] NULL,
	[iva] [float] NULL,
	[total] [float] NOT NULL,
 CONSTRAINT [PK__movimien__628521739D761145] PRIMARY KEY CLUSTERED 
(
	[idMovimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[pregunta]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[pregunta](
	[idPregunta] [int] IDENTITY(1,1) NOT NULL,
	[nombrePregunta] [varchar](45) NOT NULL,
	[estado] [varchar](10) NOT NULL,
 CONSTRAINT [PK__pregunta__754EC09E5FFC8208] PRIMARY KEY CLUSTERED 
(
	[idPregunta] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[producto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[producto](
	[IdProducto] [int] IDENTITY(1,1) NOT NULL,
	[referencia] [int] NOT NULL,
	[nombreProducto] [varchar](25) NULL,
	[descripcionProducto] [varchar](50) NULL,
	[inventario] [float] NULL,
	[stockMinimo] [float] NULL,
	[estadoProducto] [varchar](10) NOT NULL,
	[precioCompra] [float] NULL,
	[edicionLimitada] [varchar](2) NULL,
	[precio] [float] NOT NULL,
	[bdPromocion_IdPromocion] [int] NOT NULL,
	[bdClasificacionProducto_IdClasificacionProducto] [int] NOT NULL,
	[bdTalla_IdTalla] [int] NOT NULL,
	[imagen1] [varchar](1000) NULL,
	[imagen2] [varchar](1000) NULL,
	[imagen3] [varchar](1000) NULL,
	[imagen4] [varchar](1000) NULL,
	[imagen5] [varchar](1000) NULL,
	[diseno] [int] NULL,
 CONSTRAINT [PK__bdProduc__098892108DD52A2D] PRIMARY KEY CLUSTERED 
(
	[IdProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[promocion]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[promocion](
	[idPromocion] [int] IDENTITY(1,1) NOT NULL,
	[nombrePromocion] [varchar](30) NOT NULL,
	[descripcion] [varchar](40) NOT NULL,
	[porcentaje] [int] NULL,
	[efectivo] [int] NULL,
	[vigencia] [date] NULL,
	[estado] [varchar](10) NOT NULL,
 CONSTRAINT [PK__bdPromoc__35F6C2A53E68BD86] PRIMARY KEY CLUSTERED 
(
	[idPromocion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[subTipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[subTipoProducto](
	[idSubTipo] [int] IDENTITY(1,1) NOT NULL,
	[clasificacion] [varchar](45) NOT NULL,
	[estado] [varchar](25) NOT NULL,
 CONSTRAINT [PK__bdCatego__671072EDCB28B7EF] PRIMARY KEY CLUSTERED 
(
	[idSubTipo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[talla]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[talla](
	[idTalla] [int] IDENTITY(1,1) NOT NULL,
	[nombreTalla] [varchar](45) NOT NULL,
	[estado] [varchar](25) NOT NULL,
 CONSTRAINT [PK__bdTalla__E95BE943E24B7D8B] PRIMARY KEY CLUSTERED 
(
	[idTalla] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tipoMovimiento]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tipoMovimiento](
	[idTipo_movimiento] [int] IDENTITY(1,1) NOT NULL,
	[descripcioMovimiento] [varchar](45) NULL,
 CONSTRAINT [PK__tipoMovi__AE1D87E1304AF82C] PRIMARY KEY CLUSTERED 
(
	[idTipo_movimiento] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tipoProducto]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tipoProducto](
	[idTipoProducto] [int] IDENTITY(1,1) NOT NULL,
	[descripcionTipoProducto] [varchar](45) NOT NULL,
	[estado] [varchar](25) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idTipoProducto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tipoUsuario]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tipoUsuario](
	[idTipoUsuario] [int] IDENTITY(1,1) NOT NULL,
	[descripcionTipoUsuario] [varchar](45) NOT NULL,
	[estado] [varchar](25) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idTipoUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[usuarios]    Script Date: 02/04/2019 10:30:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[usuarios](
	[identificacion] [int] NOT NULL,
	[nombres] [varchar](27) NOT NULL,
	[apellidos] [varchar](27) NOT NULL,
	[idDepartamento] [int] NULL,
	[idCiudad] [int] NULL,
	[direccionResidencia] [varchar](40) NULL,
	[email] [varchar](45) NOT NULL,
	[estadoCuenta] [varchar](12) NOT NULL,
	[fechaNacimiento] [datetime] NULL,
	[password] [varchar](20) NOT NULL,
	[respuesta] [varchar](15) NOT NULL,
	[tipoUsuario_IdTipo] [int] NOT NULL,
	[pregunta_IdPregunta] [int] NOT NULL,
 CONSTRAINT [PK__usuarios__C196DEC67835F554] PRIMARY KEY CLUSTERED 
(
	[identificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[clasificacionProducto]  WITH CHECK ADD  CONSTRAINT [fk_bdClasificacionProducto_bdTipoProducto] FOREIGN KEY([tipoProducto_idTipoProducto])
REFERENCES [dbo].[tipoProducto] ([idTipoProducto])
GO
ALTER TABLE [dbo].[clasificacionProducto] CHECK CONSTRAINT [fk_bdClasificacionProducto_bdTipoProducto]
GO
ALTER TABLE [dbo].[clasificacionProducto]  WITH CHECK ADD  CONSTRAINT [fk_clasificacionProducto_idSubTipo] FOREIGN KEY([subTiposProducto_idSubTipo])
REFERENCES [dbo].[subTipoProducto] ([idSubTipo])
GO
ALTER TABLE [dbo].[clasificacionProducto] CHECK CONSTRAINT [fk_clasificacionProducto_idSubTipo]
GO
ALTER TABLE [dbo].[detalleDiseno]  WITH CHECK ADD  CONSTRAINT [fk_detallediseno_idDiseno] FOREIGN KEY([idDiseno])
REFERENCES [dbo].[diseno] ([idDiseno])
GO
ALTER TABLE [dbo].[detalleDiseno] CHECK CONSTRAINT [fk_detallediseno_idDiseno]
GO
ALTER TABLE [dbo].[detalleDiseno]  WITH CHECK ADD  CONSTRAINT [fk_detallediseno_idProducto] FOREIGN KEY([idProducto])
REFERENCES [dbo].[producto] ([IdProducto])
GO
ALTER TABLE [dbo].[detalleDiseno] CHECK CONSTRAINT [fk_detallediseno_idProducto]
GO
ALTER TABLE [dbo].[detalleMovimiento]  WITH CHECK ADD  CONSTRAINT [fk_detalleMovimiento_bdProducto] FOREIGN KEY([bdProducto_IdProducto])
REFERENCES [dbo].[producto] ([IdProducto])
GO
ALTER TABLE [dbo].[detalleMovimiento] CHECK CONSTRAINT [fk_detalleMovimiento_bdProducto]
GO
ALTER TABLE [dbo].[detalleMovimiento]  WITH CHECK ADD  CONSTRAINT [fk_detalleMovimiento_Movimiento] FOREIGN KEY([Movimiento_idMovimiento])
REFERENCES [dbo].[movimiento] ([idMovimiento])
GO
ALTER TABLE [dbo].[detalleMovimiento] CHECK CONSTRAINT [fk_detalleMovimiento_Movimiento]
GO
ALTER TABLE [dbo].[movimiento]  WITH CHECK ADD  CONSTRAINT [fk_movimiento_Tipo_movimiento] FOREIGN KEY([tipoMovimiento_idTipo_movimiento])
REFERENCES [dbo].[tipoMovimiento] ([idTipo_movimiento])
GO
ALTER TABLE [dbo].[movimiento] CHECK CONSTRAINT [fk_movimiento_Tipo_movimiento]
GO
ALTER TABLE [dbo].[movimiento]  WITH CHECK ADD  CONSTRAINT [fk_movimiento_usuarios_identificacion] FOREIGN KEY([usuarios_identificacion])
REFERENCES [dbo].[usuarios] ([identificacion])
GO
ALTER TABLE [dbo].[movimiento] CHECK CONSTRAINT [fk_movimiento_usuarios_identificacion]
GO
ALTER TABLE [dbo].[producto]  WITH CHECK ADD  CONSTRAINT [fk_producto_Clasificacion] FOREIGN KEY([bdClasificacionProducto_IdClasificacionProducto])
REFERENCES [dbo].[clasificacionProducto] ([idClasificacionProducto])
GO
ALTER TABLE [dbo].[producto] CHECK CONSTRAINT [fk_producto_Clasificacion]
GO
ALTER TABLE [dbo].[producto]  WITH CHECK ADD  CONSTRAINT [fk_producto_promocion] FOREIGN KEY([bdPromocion_IdPromocion])
REFERENCES [dbo].[promocion] ([idPromocion])
GO
ALTER TABLE [dbo].[producto] CHECK CONSTRAINT [fk_producto_promocion]
GO
ALTER TABLE [dbo].[producto]  WITH CHECK ADD  CONSTRAINT [fk_producto_talla] FOREIGN KEY([bdTalla_IdTalla])
REFERENCES [dbo].[talla] ([idTalla])
GO
ALTER TABLE [dbo].[producto] CHECK CONSTRAINT [fk_producto_talla]
GO
ALTER TABLE [dbo].[usuarios]  WITH CHECK ADD  CONSTRAINT [fk_bdUsuario_bdPregunta1] FOREIGN KEY([pregunta_IdPregunta])
REFERENCES [dbo].[pregunta] ([idPregunta])
GO
ALTER TABLE [dbo].[usuarios] CHECK CONSTRAINT [fk_bdUsuario_bdPregunta1]
GO
ALTER TABLE [dbo].[usuarios]  WITH CHECK ADD  CONSTRAINT [fk_bdUsuario_bdTipoUsuario] FOREIGN KEY([tipoUsuario_IdTipo])
REFERENCES [dbo].[tipoUsuario] ([idTipoUsuario])
GO
ALTER TABLE [dbo].[usuarios] CHECK CONSTRAINT [fk_bdUsuario_bdTipoUsuario]
GO
ALTER TABLE [dbo].[usuarios]  WITH CHECK ADD  CONSTRAINT [fk_departamento_idCiudad] FOREIGN KEY([idCiudad])
REFERENCES [dbo].[ciudades] ([idCiudad])
GO
ALTER TABLE [dbo].[usuarios] CHECK CONSTRAINT [fk_departamento_idCiudad]
GO
ALTER TABLE [dbo].[usuarios]  WITH CHECK ADD  CONSTRAINT [fk_departamento_idDepartamento] FOREIGN KEY([idDepartamento])
REFERENCES [dbo].[departamentos] ([idDepartamento])
GO
ALTER TABLE [dbo].[usuarios] CHECK CONSTRAINT [fk_departamento_idDepartamento]
GO
USE [master]
GO
ALTER DATABASE [Fearless_Style] SET  READ_WRITE 
GO
