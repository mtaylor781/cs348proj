--getFlightsTo takes in destination and returns table with flights to destination
DELIMITER //
CREATE PROCEDURE getFlightsTo (IN dest VARCHAR(30))
BEGIN
  SELECT destination, date, seatsFilled, maxPassengers
  FROM Flight f
  JOIN Airplane 
  ON f.airplaneID = a.airplaneID
  WHERE destination = dest;
END //
DELIMITER ;


--Creates trip with passengerID, flightID, and numberBags as inputs
DELIMITER //
CREATE PROCEDURE CreateTrip (IN passID VARCHAR(30), IN flight_id INT, IN numBags INT)
BEGIN
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
  START TRANSACTION;
  SET @maxPass = (SELECT maxPassengers FROM Flight JOIN Airplane WHERE Flight.airplaneID = Airplane.airplaneID AND Flight.flightID = flight_id);
  SET @currPass = (SELECT seatsFilled FROM Flight f WHERE f.flightID = flight_id);
  IF @currPass < @maxPass THEN
    SET @confirmationID = (SELECT MAX(confirmationID) FROM Trip) + 1;
    SET @seatNum = (SELECT MAX(seatID) FROM Trip) + 1;
    INSERT INTO Trip VALUES (@confirmationID, passID, flight_id, @seatNum, numBags);
    SET @currPass = @currPass + 1;
    UPDATE Flight SET seatsFilled = @currPass
    WHERE flightID = flight_id;
  ELSE
    SET @confirmationID = NULL;
  END IF;
  SELECT @confirmationID;
  COMMIT;
END //
DELIMITER ;


--Deletes trip by confirmation number and updates seats availible
DELIMITER //
CREATE PROCEDURE DeleteTrip (IN confirm INT)
BEGIN
  SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
  START TRANSACTION;
  DELETE FROM Trip WHERE confirmationID = confirm;
  SET @flight_id = (SELECT Trip.flightID FROM Flight JOIN Trip ON Flight.flightID = Trip.flightID WHERE confirmationID = confirm);
  SET @newSeats = (SELECT seatsFilled FROM Flight WHERE flightID = @flight_id) - 1;
  UPDATE Flight SET seatsFilled = @newSeats
  WHERE flightID = @flight_id;
  COMMIT;
END //
DELIMITER ;
