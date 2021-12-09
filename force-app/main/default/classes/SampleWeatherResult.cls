@JsonAccess(serializable = 'always' deserializable = 'always')
public class SampleWeatherResult {
    public class TCoord {
        public Decimal lon;
        public Decimal lat;
    }

    public class TWeather {
        public Long id;
        public String main;
        public String description;
        public String icon;
    }

    public class TMain {
        public Decimal temp;
        public Long pressure;
        public Long humidity;
        public Decimal temp_min;
        public Decimal temp_max;
    }

    public class TWind {
        public Decimal speed;
        public Long deg;
    }

    public class TClouds {
        public Long all;
    }

    public class TSys {
        public Long type;
        public Long id;
        public Decimal message;
        public String country;
        public Long sunrise;
        public Long sunset;
    }

    public TCoord coord;
    public List<TWeather> weather;
    public String base;
    public TMain main;
    public Long visibility;
    public TWind wind;
    public TClouds clouds;
    public String dt;
    public TSys sys;
    public String id;
    public String name;
    public String cod;
}