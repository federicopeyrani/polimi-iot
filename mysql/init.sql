DELIMITER $$

CREATE TABLE IF NOT EXISTS exposure_notifications
(
    node_id         int NOT NULL,
    sender_id       int NOT NULL,
    message_counter int NOT NULL,
    counter         int default 0,
    PRIMARY KEY (node_id, sender_id)
)$$

CREATE TABLE IF NOT EXISTS exposures
(
    node_id_1 int       NOT NULL,
    node_id_2 int       NOT NULL,
    date      timestamp NOT NULL,
    delivered boolean default false,
    PRIMARY KEY (node_id_1, node_id_2, date)
)$$

CREATE TRIGGER check_subsequent_message
    BEFORE UPDATE
    ON exposure_notifications
    FOR EACH ROW
    -- only increment the counter if the "message_counter" field of the received
    -- message is not too far off from the previous value, so to keep track of
    -- consecutive messages
    IF NEW.message_counter > OLD.message_counter AND NEW.message_counter <= OLD.message_counter + 4 THEN
        SET NEW.counter = OLD.counter + 1;
    ELSE
        SET NEW.counter = 0;
    END IF;
$$

CREATE TRIGGER check_exposure
    BEFORE UPDATE
    ON exposure_notifications
    FOR EACH ROW
    -- if the counter reaches a particular value, insert an entry inside "exposures"
    -- and reset the counter
    IF NEW.counter >= 10 THEN
        BEGIN
            INSERT INTO exposures (node_id_1, node_id_2, date) VALUES (NEW.node_id, NEW.sender_id, current_timestamp);
            SET NEW.counter = 0;
        END;
    END IF;
$$

DELIMITER ;