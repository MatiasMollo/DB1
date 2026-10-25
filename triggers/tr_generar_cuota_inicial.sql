/*
Genera la cuota inicial de un gasto
*/
CREATE OR ALTER TRIGGER tr_generar_cuota_incial
ON gastos
AFTER INSERT
AS 
BEGIN
	INSERT INTO cuotas (gasto_id, numero, vencimiento, monto) VALUES (
		(SELECT id FROM inserted),
		1,
		(SELECT fecha FROM inserted),
		(SELECT monto FROM inserted)
	);
END;